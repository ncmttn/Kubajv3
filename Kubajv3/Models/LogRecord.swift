import Foundation
import SwiftData

@Model
final class LogRecord {
    var diameterCm: Double
    var lengthM: Double
    var quantity: Int
    var volumeM3: Double
    var calculationMethod: CalculationMethod
    var isHollow: Bool
    var createdAt: Date

    var istif: Istif?

    init(
        diameterCm: Double,
        lengthM: Double,
        quantity: Int,
        volumeM3: Double,
        calculationMethod: CalculationMethod,
        isHollow: Bool = false,
        createdAt: Date = .now,
        istif: Istif? = nil
    ) {
        self.diameterCm = diameterCm
        self.lengthM = lengthM
        self.quantity = quantity
        self.volumeM3 = volumeM3
        self.calculationMethod = calculationMethod
        self.isHollow = isHollow
        self.createdAt = createdAt
        self.istif = istif
    }
}
