import SwiftUI

struct ProductRecommendationRowView: View {
    let product: ProductRecommendation
    @Environment(ShopStore.self) private var shopStore

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(product.name)
                    .font(.subheadline)
                Text("Art. nr: \(product.articleNumber)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Order") {
                shopStore.addToCart(product)
            }
            .font(.caption)
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
