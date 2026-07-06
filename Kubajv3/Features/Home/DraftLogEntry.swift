import Foundation

struct DraftLogEntry: Identifiable, Equatable, Sendable {
    let id: UUID
    var diameterCm: Double
    var lengthM: Double
    var quantity: Int
    var volumeM3: Double
    var calculationMethod: CalculationMethod
    var isHollow: Bool
    let createdAt: Date

    var totalVolumeM3: Double {
        volumeM3 * Double(quantity)
    }
}
