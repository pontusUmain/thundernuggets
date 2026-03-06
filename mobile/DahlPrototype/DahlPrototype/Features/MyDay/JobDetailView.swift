import SwiftUI

struct JobDetailView: View {
    let job: Job

    var body: some View {
        List {
            Section("Job Info") {
                LabeledContent("Project", value: job.projectName)
                LabeledContent("Address", value: job.clientAddress)
                LabeledContent("Start", value: job.scheduledStart.formatted(date: .abbreviated, time: .shortened))
                LabeledContent("Status", value: statusLabel)
            }

            Section("Materials") {
                if job.materials.isEmpty {
                    Text("No materials listed.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(job.materials) { material in
                        MaterialRowView(material: material)
                    }
                }
            }

            Section {
                Button("Navigate to site") {
                    openInMaps(address: job.clientAddress)
                }
            }
        }
        .navigationTitle(job.projectName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var statusLabel: String {
        switch job.status {
        case .onTrack:          return "On track"
        case .missingMaterials: return "Missing materials"
        case .unconfirmed:      return "Unconfirmed"
        }
    }

    private func openInMaps(address: String) {
        let encoded = address.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let url = URL(string: "maps://?q=\(encoded)") {
            UIApplication.shared.open(url)
        }
    }
}

private struct MaterialRowView: View {
    let material: JobMaterial

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(material.productName)
                Text("Needed: \(material.needed)  Ordered: \(material.ordered)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if material.delivered {
                Text("Delivered")
                    .font(.caption)
                    .foregroundStyle(.green)
            } else if material.ordered < material.needed {
                Text("Not ordered")
                    .font(.caption)
                    .foregroundStyle(.red)
            } else {
                Text("Pending delivery")
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
    }
}
