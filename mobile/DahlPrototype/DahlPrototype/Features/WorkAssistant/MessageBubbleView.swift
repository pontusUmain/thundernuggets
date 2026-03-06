import SwiftUI

struct MessageBubbleView: View {
    let message: AIMessage

    var body: some View {
        VStack(alignment: message.role == .user ? .trailing : .leading, spacing: 8) {
            HStack {
                if message.role == .user { Spacer() }
                Text(message.text)
                    .padding(10)
                    .background(message.role == .user ? Color.accentColor : Color(.systemGray5))
                    .foregroundStyle(message.role == .user ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: 300, alignment: message.role == .user ? .trailing : .leading)
                if message.role == .assistant { Spacer() }
            }

            if !message.products.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Recommended products")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    ForEach(message.products) { product in
                        ProductRecommendationRowView(product: product)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}
