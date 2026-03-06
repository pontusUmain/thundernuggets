import SwiftUI

struct ProductRecommendationRowView: View {
    let product: ProductRecommendation

    private var formattedPrice: String {
        let value = Double(product.price) / 100.0
        return String(format: "%.0f %@", value, product.currency)
    }

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.subheadline)
                Text("SKU: \(product.sku)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(formattedPrice)
                    .font(.subheadline)
                Button("Order") {
                    // Order flow — to be implemented in E-Commerce feature
                }
                .font(.caption)
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
