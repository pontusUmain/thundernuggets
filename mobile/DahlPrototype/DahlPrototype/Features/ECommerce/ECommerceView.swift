import SwiftUI

struct ECommerceView: View {
    @Environment(ShopStore.self) private var store
    @State private var searchText = ""
    @State private var showCart = false

    private var filteredProducts: [ProductRecommendation] {
        if searchText.isEmpty { return store.allProducts }
        return store.allProducts.filter {
            $0.name.localizedCaseInsensitiveContains(searchText) ||
            $0.sku.localizedCaseInsensitiveContains(searchText)
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
            .searchable(text: $searchText, prompt: "Search by name or SKU")
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

    private var productList: some View {
        List(filteredProducts) { product in
            ProductRowView(product: product, store: store)
        }
    }
}

#Preview {
    ECommerceView()
        .environment(ShopStore())
}
