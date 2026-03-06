import SwiftUI

struct CartView: View {
    let store: ShopStore
    @Environment(\.dismiss) private var dismiss
    @State private var isPlacingOrder = false

    private var formattedTotal: String {
        let value = Double(store.cartTotal) / 100.0
        return String(format: "%.0f SEK", value)
    }

    var body: some View {
        NavigationStack {
            Group {
                if store.orderPlaced {
                    orderConfirmation
                } else if store.cart.isEmpty {
                    Text("Your cart is empty.")
                        .foregroundStyle(.secondary)
                } else {
                    cartContent
                }
            }
            .navigationTitle("Cart")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }

    private var cartContent: some View {
        List {
            ForEach(store.cart) { item in
                CartItemRowView(item: item) { qty in
                    store.updateQuantity(item, quantity: qty)
                }
            }

            Section {
                HStack {
                    Text("Total")
                        .font(.headline)
                    Spacer()
                    Text(formattedTotal)
                        .font(.headline)
                }
            }

            Section {
                Button {
                    Task {
                        isPlacingOrder = true
                        await store.placeOrder()
                        isPlacingOrder = false
                    }
                } label: {
                    if isPlacingOrder {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else {
                        Text("Place Order")
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
                .disabled(isPlacingOrder)
            }
        }
    }

    private var orderConfirmation: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("Order placed!")
                .font(.title2)
            Text("Your order has been submitted successfully.")
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button("Close") { dismiss() }
                .padding(.top)
        }
        .padding()
    }
}

private struct CartItemRowView: View {
    let item: CartItem
    let onQuantityChange: (Int) -> Void

    private func formatted(_ ore: Int) -> String {
        String(format: "%.0f SEK", Double(ore) / 100.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.product.name)
                .font(.body)
            Text("SKU: \(item.product.sku)")
                .font(.caption)
                .foregroundStyle(.secondary)
            HStack {
                Stepper(
                    "\(item.quantity) × \(formatted(item.product.price))",
                    value: Binding(
                        get: { item.quantity },
                        set: { onQuantityChange($0) }
                    ),
                    in: 0...999
                )
                Spacer()
                Text(formatted(item.totalPrice))
                    .font(.subheadline)
                    .bold()
            }
        }
        .padding(.vertical, 2)
    }
}
