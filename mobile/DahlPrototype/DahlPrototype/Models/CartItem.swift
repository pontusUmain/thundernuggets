import Foundation

struct CartItem: Identifiable {
    let id: UUID
    let product: ProductRecommendation
    var quantity: Int

    init(product: ProductRecommendation, quantity: Int = 1) {
        self.id = UUID()
        self.product = product
        self.quantity = quantity
    }

    var totalPrice: Int { product.price * quantity }
}
