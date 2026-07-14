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
    var isLumber: Bool?
    var topDiameterCm: Double?
    var midDiameterCm: Double?
    var buttDiameterCm: Double?
    var lumberThicknessCm: Double?
    var createdAt: Date

    var folder: Folder?

    var isLumberEntry: Bool {
        isLumber ?? false
    }

    init(
        diameterCm: Double,
        lengthM: Double,
        quantity: Int,
        volumeM3: Double,
        calculationMethod: CalculationMethod,
        isHollow: Bool = false,
        isLumber: Bool = false,
        topDiameterCm: Double? = nil,
        midDiameterCm: Double? = nil,
        buttDiameterCm: Double? = nil,
        lumberThicknessCm: Double? = nil,
        createdAt: Date = .now,
        folder: Folder? = nil
    ) {
        self.diameterCm = diameterCm
        self.lengthM = lengthM
        self.quantity = quantity
        self.volumeM3 = volumeM3
        self.calculationMethod = calculationMethod
        self.isHollow = isHollow
        self.isLumber = isLumber
        self.topDiameterCm = topDiameterCm
        self.midDiameterCm = midDiameterCm
        self.buttDiameterCm = buttDiameterCm
        self.lumberThicknessCm = lumberThicknessCm
        self.createdAt = createdAt
        self.folder = folder
    }
}
