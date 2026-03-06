import SwiftUI

struct MyDayJobRowView: View {
    let job: Job

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(job.scheduledStart.formatted(date: .omitted, time: .shortened))
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(job.projectName)
                .font(.headline)
            Text(job.clientAddress)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(statusLabel)
                .font(.caption)
                .foregroundStyle(statusColor)
        }
        .padding(.vertical, 4)
    }

    private var statusLabel: String {
        switch job.status {
        case .onTrack:          return "On track"
        case .missingMaterials: return "Missing materials"
        case .unconfirmed:      return "Unconfirmed"
        }
    }

    private var statusColor: Color {
        switch job.status {
        case .onTrack:          return .primary
        case .missingMaterials: return .orange
        case .unconfirmed:      return .red
        }
    }
}
