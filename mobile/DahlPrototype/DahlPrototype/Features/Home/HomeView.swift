import SwiftUI

struct HomeView: View {
    @Binding var selectedTab: Int
    @State private var store = HomeStore()
    @State private var bannerAnimating = false

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
        List {
            aiBanner
                .listRowInsets(EdgeInsets())
                .listRowSeparator(.hidden)

            ForEach(store.jobs) { job in
                JobRowView(job: job)
            }
        }
    }

    // MARK: - AI Assistant Banner

    private var aiBanner: some View {
        Button {
            withAnimation { selectedTab = 3 }
        } label: {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.2))
                        .frame(width: 44, height: 44)
                    Image(systemName: "sparkles")
                        .font(.title2)
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse, options: .repeating, isActive: bannerAnimating)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("AI-assistent")
                        .font(.headline)
                        .foregroundStyle(.white)
                    Text("Behover du hjalp? Fraga mig!")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.7))
            }
            .padding(16)
            .background {
                LinearGradient(
                    colors: [Color.accentColor, Color.accentColor.opacity(0.7)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: Color.accentColor.opacity(0.35), radius: 10, y: 5)
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
        .onAppear { bannerAnimating = true }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
}
