import SwiftUI

struct MyDayView: View {
    @State private var store = MyDayStore()

    var body: some View {
        NavigationStack {
            Group {
                switch store.loadingState {
                case .idle, .loading:
                    ProgressView("Loading schedule...")
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
            .navigationTitle("My Day")
            .task { await store.loadJobs() }
        }
    }

    private var jobList: some View {
        List(store.jobs) { job in
            NavigationLink(destination: JobDetailView(job: job)) {
                MyDayJobRowView(job: job)
            }
        }
    }
}

#Preview {
    MyDayView()
}
