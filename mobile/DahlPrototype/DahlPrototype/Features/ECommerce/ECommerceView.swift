import SwiftUI

struct ECommerceView: View {
    @Environment(ShopStore.self) private var store
    @State private var searchText = ""
    @State private var showCart = false
    @State private var visibleProductIDs: Set<String> = []
    @Namespace private var chipNamespace

    private var filteredProducts: [ProductRecommendation] {
        let base = store.filteredProducts
        if searchText.isEmpty { return base }
        return base.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.articleNumber.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                switch store.loadingState {
                case .idle, .loading:
                    ProgressView("Loading products...")
                case .failed(let message):
                    VStack(spacing: 16) {
                        Text(message)
                        Button("Retry") { Task { await store.loadProducts() } }
                    }
                case .loaded:
                    productList
                }
            }
            .navigationTitle("Shop")
            .searchable(text: $searchText, prompt: "Search by name or article number")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showCart = true
                    } label: {
                        Label("Cart", systemImage: "cart")
                    }
                    .badge(store.cartItemCount)
                }
            }
            .sheet(isPresented: $showCart) {
                CartView(store: store)
            }
            .task { await store.loadProducts() }
        }
    }

    // MARK: - Category Chips

    private var categoryChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                chipButton(id: "all", label: "Alla", isSelected: store.selectedCategory == nil) {
                    store.selectedCategory = nil
                }
                ForEach(store.categories) { category in
                    chipButton(id: category.slug, label: category.name, isSelected: store.selectedCategory?.slug == category.slug) {
                        if store.selectedCategory?.slug == category.slug {
                            store.selectedCategory = nil
                        } else {
                            store.selectedCategory = category
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }

    private func staggerIn(products: [ProductRecommendation]) {
        visibleProductIDs = []
        for (index, product) in products.enumerated() {
            withAnimation(.snappy(duration: 0.35).delay(Double(index) * 0.06)) {
                visibleProductIDs.insert(product.id)
            }
        }
    }

    private func chipButton(id: String, label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button {
            withAnimation(.snappy(duration: 0.3)) {
                action()
            }
            staggerIn(products: filteredProducts)
        } label: {
            Text(label)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .foregroundStyle(isSelected ? .white : .primary)
                .background {
                    if isSelected {
                        Capsule()
                            .fill(Color.accentColor)
                            .matchedGeometryEffect(id: "activeChip", in: chipNamespace)
                    } else {
                        Capsule()
                            .fill(Color(.systemGray5))
                    }
                }
                .clipShape(Capsule())
        }
    }

    // MARK: - Product List

    private var productList: some View {
        List {
            Section {
                categoryChips
                    .listRowInsets(EdgeInsets())
                    .listRowSeparator(.hidden)
            }
            if filteredProducts.isEmpty {
                ContentUnavailableView(
                    "Inga produkter",
                    systemImage: "magnifyingglass",
                    description: Text("Inga produkter matchar din filtrering.")
                )
                .listRowSeparator(.hidden)
            } else {
                ForEach(Array(filteredProducts.enumerated()), id: \.element.id) { index, product in
                    ProductRowView(product: product, store: store)
                        .opacity(visibleProductIDs.contains(product.id) ? 1 : 0)
                        .offset(y: visibleProductIDs.contains(product.id) ? 0 : 20)
                }
            }
        }
        .listStyle(.plain)
        .animation(.snappy(duration: 0.35), value: searchText)
        .onAppear { staggerIn(products: filteredProducts) }
    }
}

#Preview {
    ECommerceView()
        .environment(ShopStore())
}
