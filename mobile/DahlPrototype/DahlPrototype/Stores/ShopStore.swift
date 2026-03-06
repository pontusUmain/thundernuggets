import Foundation

@Observable
final class ShopStore {
    var allProducts: [ProductRecommendation] = []
    var categories: [Category] = []
    var selectedCategory: Category?
    var cart: [CartItem] = []
    var loadingState: LoadingState = .idle
    var orderPlaced = false

    enum LoadingState {
        case idle, loading, loaded, failed(String)
    }

    var cartItemCount: Int {
        cart.reduce(0) { $0 + $1.quantity }
    }

    var cartTotal: Int {
        cart.reduce(0) { $0 + $1.totalPrice }
    }

    var filteredProducts: [ProductRecommendation] {
        guard let selected = selectedCategory else { return allProducts }
        return allProducts.filter { $0.categorySlug == selected.slug }
    }

    func loadProducts() async {
        loadingState = .loading
        do {
            allProducts = try JsonHandler.load("products", as: [ProductRecommendation].self)
            categories = try JsonHandler.load("categories", as: [Category].self)
            loadingState = .loaded
        } catch {
            loadingState = .failed("Could not load products.")
        }
    }

    func quantity(for product: ProductRecommendation) -> Int {
        cart.first(where: { $0.product.id == product.id })?.quantity ?? 0
    }

    func setQuantity(_ quantity: Int, for product: ProductRecommendation) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            if quantity <= 0 {
                cart.remove(at: index)
            } else {
                cart[index].quantity = quantity
            }
        } else if quantity > 0 {
            cart.append(CartItem(product: product, quantity: quantity))
        }
    }

    func addToCart(_ product: ProductRecommendation) {
        if let index = cart.firstIndex(where: { $0.product.id == product.id }) {
            cart[index].quantity += 1
        } else {
            cart.append(CartItem(product: product))
        }
    }

    func removeFromCart(_ item: CartItem) {
        cart.removeAll { $0.id == item.id }
    }

    func updateQuantity(_ item: CartItem, quantity: Int) {
        guard let index = cart.firstIndex(where: { $0.id == item.id }) else { return }
        if quantity <= 0 {
            cart.remove(at: index)
        } else {
            cart[index].quantity = quantity
        }
    }

    func placeOrder() async {
        // Simulate order submission
        try? await Task.sleep(for: .seconds(1))
        cart.removeAll()
        orderPlaced = true
    }
}
