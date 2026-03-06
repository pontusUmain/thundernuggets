import Foundation

@Observable
final class MyDayStore {
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
            let loaded = try JsonHandler.load("jobs_today", as: [Job].self, decoder: decoder)
            jobs = loaded.sorted { $0.scheduledStart < $1.scheduledStart }
            loadingState = .loaded
        } catch {
            loadingState = .failed("Could not load today's schedule.")
        }
    }
}
