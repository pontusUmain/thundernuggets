import Foundation

struct Category: Identifiable, Codable {
    let slug: String
    let name: String
    let subcategories: [Subcategory]

    var id: String { slug }

    struct Subcategory: Identifiable, Codable {
        let slug: String
        let name: String
        var id: String { slug }
    }
}
