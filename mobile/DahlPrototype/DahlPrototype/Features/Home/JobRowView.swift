import SwiftUI

struct JobRowView: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(job.projectName)
                .font(.headline)
            Text(job.scheduledStart.formatted(date: .omitted, time: .shortened))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(job.clientAddress)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(statusLabel)
                .font(.caption)
                .foregroundStyle(statusColor)
            Button("Navigate") {
                openInMaps(address: job.clientAddress)
            }
            .padding(.top, 4)
        }
        .padding(.vertical, 4)
    }

    private var statusLabel: String {
        switch job.status {
        case .onTrack:         return "On track"
        case .missingMaterials: return "Missing materials"
        case .unconfirmed:     return "Unconfirmed"
        }
    }

    private var statusColor: Color {
        switch job.status {
        case .onTrack:          return .primary
        case .missingMaterials: return .orange
        case .unconfirmed:      return .red
        }
    }

    private func openInMaps(address: String) {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}
