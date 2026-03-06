import Foundation

enum JsonHandlerError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String, Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "JSON file '\(filename).json' not found in bundle."
        case .decodingFailed(let filename, let error):
            return "Failed to decode '\(filename).json': \(error.localizedDescription)"
        }
    }
}

enum JsonHandler {
    static func load<T: Decodable>(
        _ filename: String,
        as type: T.Type = T.self,
        decoder: JSONDecoder = JSONDecoder()
    ) throws -> T {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            throw JsonHandlerError.fileNotFound(filename)
        }
        do {
            let data = try Data(contentsOf: url)
            return try decoder.decode(T.self, from: data)
        } catch let error as JsonHandlerError {
            throw error
        } catch {
            throw JsonHandlerError.decodingFailed(filename, error)
        }
    }
}
