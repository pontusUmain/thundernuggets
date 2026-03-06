import SwiftUI

struct ProductRowView: View {
    let product: ProductRecommendation
    let store: ShopStore

    private var quantity: Int { store.quantity(for: product) }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(product.name)
                    .font(.body)
                Text("Art. nr: \(product.articleNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if !product.brandName.isEmpty {
                    Text(product.brandName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
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
