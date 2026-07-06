import Foundation

struct GroupedExportRow: Identifiable, Sendable {
    let id: String
    let diameterCm: Double
    let lengthM: Double
    let quantity: Int
    let totalVolumeM3: Double

    init(group: LogGroup) {
        id = group.id
        diameterCm = group.diameterCm
        lengthM = group.lengthM
        quantity = group.totalQuantity
        totalVolumeM3 = group.totalVolumeM3
    }
}

struct ExportMetadata: Sendable {
    let optionalLines: [String]

    static let maximumFieldCount = 5

    init(fields: [String]) {
        optionalLines = fields
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .prefix(Self.maximumFieldCount)
            .map { String($0) }
    }
}

enum ExportKind: Sendable {
    case pdf
    case csv
}
