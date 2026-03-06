import SwiftUI

struct WorkAssistantView: View {
    @State private var store = AIStore()
    @State private var inputText = ""
    @FocusState private var inputFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                messageList
                Divider()
                inputBar
            }
            .navigationTitle("Assistant")
        }
    }

    // MARK: - Message list

    private var messageList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 16) {
                    if store.messages.isEmpty {
                        emptyState
                    } else {
                        ForEach(store.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                        if store.isThinking {
                            thinkingIndicator
                                .id("thinking")
                        }
                        if let error = store.error {
                            Text(error)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                                .id("error")
                        }
                    }
                }
                .padding()
            }
            .onChange(of: store.messages.count) {
                scrollToBottom(proxy: proxy)
            }
            .onChange(of: store.isThinking) {
                scrollToBottom(proxy: proxy)
            }
        }
    }

    private var emptyState: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Describe a problem you're facing on site.")
                .foregroundStyle(.secondary)
            Text("For example: The 22mm copper fitting won't seat on the press tool.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var thinkingIndicator: some View {
        Text("Thinking…")
            .font(.subheadline)
            .foregroundStyle(.secondary)
            .padding(.horizontal)
    }

    // MARK: - Input bar

    private var inputBar: some View {
        HStack(alignment: .bottom, spacing: 8) {
            TextField("Describe your problem…", text: $inputText, axis: .vertical)
                .lineLimit(1...5)
                .focused($inputFocused)
                .padding(8)
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Button("Send") {
                submitPrompt()
            }
            .disabled(inputText.trimmingCharacters(in: .whitespaces).isEmpty || store.isThinking)
        }
        .padding()
    }

    // MARK: - Actions

    private func submitPrompt() {
        let prompt = inputText
        inputText = ""
        inputFocused = false
        Task { await store.send(prompt: prompt) }
    }

    private func scrollToBottom(proxy: ScrollViewProxy) {
        if store.isThinking {
            proxy.scrollTo("thinking", anchor: .bottom)
        } else if let last = store.messages.last {
            proxy.scrollTo(last.id, anchor: .bottom)
        }
    }
}

#Preview {
    WorkAssistantView()
}
