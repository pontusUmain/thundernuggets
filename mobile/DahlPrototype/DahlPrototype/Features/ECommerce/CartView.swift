import SwiftUI

struct CartView: View {
    let store: ShopStore
    @Environment(\.dismiss) private var dismiss
    @State private var isPlacingOrder = false

    private var itemCountText: String {
        let count = store.cartItemCount
        return "\(count) item\(count == 1 ? "" : "s")"
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
                    Text("Items")
                        .font(.headline)
                    Spacer()
                    Text(itemCountText)
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

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(item.product.name)
                .font(.body)
            Text("Art. nr: \(item.product.articleNumber)")
                .font(.caption)
                .foregroundStyle(.secondary)
            Stepper(
                "Qty: \(item.quantity)",
                value: Binding(
                    get: { item.quantity },
                    set: { onQuantityChange($0) }
                ),
                in: 0...999
            )
        }
        .padding(.vertical, 2)
    }
}
