import SwiftUI

struct HomeView: View {
    @State private var store = HomeStore()

    var body: some View {
        NavigationStack {
            Group {
                switch store.loadingState {
                case .idle, .loading:
                    ProgressView("Loading today's jobs...")
                case .failed(let message):
                    VStack(spacing: 16) {
                        Text(message)
                        Button("Retry") {
                            Task { await store.loadJobs() }
                        }
                    }
                case .loaded where store.jobs.isEmpty:
                    Text("No jobs scheduled for today.")
                        .foregroundStyle(.secondary)
                case .loaded:
                    jobList
                }
            }
            .navigationTitle("Today")
            .task { await store.loadJobs() }
        }
    }

    private var jobList: some View {
        List(store.jobs) { job in
            JobRowView(job: job)
        }
    }
}

#Preview {
    HomeView()
}
