import Foundation

struct AIMessage: Identifiable {
    let id: UUID
    let role: Role
    let text: String
    let products: [ProductRecommendation]

    enum Role {
        case user, assistant
    }

    init(role: Role, text: String, products: [ProductRecommendation] = []) {
        self.id = UUID()
        self.role = role
        self.text = text
        self.products = products
    }
}

struct ProductRecommendation: Identifiable, Codable {
    let id: String
    let name: String
    let sku: String
    let price: Int       // öre
    let currency: String
}
