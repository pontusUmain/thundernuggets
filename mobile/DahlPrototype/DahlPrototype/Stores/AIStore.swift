import Foundation

@Observable
final class AIStore {
    var messages: [AIMessage] = []
    var isThinking = false
    var error: String? = nil

    func send(prompt: String) async {
        guard !prompt.trimmingCharacters(in: .whitespaces).isEmpty else { return }

        messages.append(AIMessage(role: .user, text: prompt))
        isThinking = true
        error = nil

        // Simulate network latency for prototype
        try? await Task.sleep(for: .seconds(1.2))

        do {
            let response = try JsonHandler.load("ai_response", as: MockAIResponse.self)
            messages.append(AIMessage(role: .assistant, text: response.text, products: response.products))
        } catch {
            self.error = "Unable to reach the assistant. Check your connection."
        }

        isThinking = false
    }
}

// Decodable container for mock JSON
private struct MockAIResponse: Decodable {
    let text: String
    let products: [ProductRecommendation]
}
