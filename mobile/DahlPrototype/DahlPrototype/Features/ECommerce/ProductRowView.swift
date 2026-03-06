import SwiftUI

struct ProductRowView: View {
    let product: ProductRecommendation
    let store: ShopStore

    private var quantity: Int { store.quantity(for: product) }

    private var formattedPrice: String {
        String(format: "%.0f %@", Double(product.price) / 100.0, product.currency)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.body)
                Text("SKU: \(product.sku)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formattedPrice)
                    .font(.subheadline)
            }
            Spacer()
            if quantity == 0 {
                Button("Add") {
                    store.setQuantity(1, for: product)
                }
                .buttonStyle(.bordered)
            } else {
                Stepper("\(quantity)", value: Binding(
                    get: { quantity },
                    set: { store.setQuantity($0, for: product) }
                ), in: 0...999)
                .fixedSize()
            }
        }
        .padding(.vertical, 2)
    }
}
