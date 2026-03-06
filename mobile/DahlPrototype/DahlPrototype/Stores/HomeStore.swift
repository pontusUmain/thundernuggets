import Foundation

@Observable
final class HomeStore {
    var jobs: [Job] = []
    var loadingState: LoadingState = .idle

    enum LoadingState {
        case idle, loading, loaded, failed(String)
    }

    func loadJobs() async {
        loadingState = .loading
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            jobs = try JsonHandler.load("jobs_today", as: [Job].self, decoder: decoder)
            loadingState = .loaded
        } catch {
            loadingState = .failed("Could not load today's jobs.")
        }
    }
}
