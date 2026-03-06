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
    let articleNumber: String
    let brands: [Brand]
    let attributes: [ProductAttribute]
    let images: [ProductImage]
    let discontinued: Bool

    var brandName: String { brands.first?.brand ?? "" }
    var imageURL: URL? { images.first.flatMap { URL(string: $0.assetUrl) } }

    struct Brand: Codable {
        let brand: String
        let assetUrl: String
    }

    struct ProductAttribute: Codable {
        let attributeName: String
        let attributeLabel: String
        let attributeValue: String
        let sort: Int
    }

    struct ProductImage: Codable {
        let assetUrl: String
        let assetType: String
    }
}
