import Foundation

struct Job: Identifiable, Codable {
    let id: String
    let projectName: String
    let clientAddress: String
    let scheduledStart: Date
    let status: JobStatus
    let materials: [JobMaterial]

    enum JobStatus: String, Codable {
        case onTrack
        case missingMaterials
        case unconfirmed
    }
}

struct JobMaterial: Identifiable, Codable {
    let id: String
    let productName: String
    let needed: Int
    let ordered: Int
    let delivered: Bool
}
