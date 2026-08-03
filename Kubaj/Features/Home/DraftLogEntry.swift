import Foundation

struct DraftLogEntry: Identifiable, Equatable, Codable, Sendable {
    let id: UUID
    var diameterCm: Double
    var lengthM: Double
    var quantity: Int
    var volumeM3: Double
    var calculationMethod: CalculationMethod
    var isHollow: Bool
    var isLumber: Bool
    var topDiameterCm: Double?
    var midDiameterCm: Double?
    var buttDiameterCm: Double?
    var lumberThicknessCm: Double?
    let createdAt: Date

    var totalVolumeM3: Double {
        volumeM3 * Double(quantity)
    }
}

enum ActiveSessionStore {
    private static let fileName = "active-session-drafts.json"

    private static var fileURL: URL {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        let directory = support.appendingPathComponent("Kubaj", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory.appendingPathComponent(fileName)
    }

    static func load() -> [DraftLogEntry] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        return (try? JSONDecoder().decode([DraftLogEntry].self, from: data)) ?? []
    }

    static func save(_ entries: [DraftLogEntry]) {
        guard let data = try? JSONEncoder().encode(entries) else {
            return
        }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
