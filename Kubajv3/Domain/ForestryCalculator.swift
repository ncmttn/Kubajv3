import Foundation

struct HollowCalculationResult: Equatable, Sendable {
    let netVolumeM3: Double
    let equivalentSolidDiameterCm: Int
}

struct ForestryCalculator: Sendable {
    static func standardCylinder(diameterCm: Double, lengthM: Double) -> Double {
        let radiusM = diameterCm / VolumeConstant.diameterToRadiusM
        let volume = Double.pi * radiusM * radiusM * lengthM
        return roundVolume(volume)
    }

    static func smalian(topDiameterCm: Double, buttDiameterCm: Double, lengthM: Double) -> Double {
        let diameterSum = topDiameterCm * topDiameterCm
            + topDiameterCm * buttDiameterCm
            + buttDiameterCm * buttDiameterCm
        let volume = Double.pi * lengthM * diameterSum / VolumeConstant.smalianDivisor
        return roundVolume(volume)
    }

    static func huber(midDiameterCm: Double, lengthM: Double) -> Double {
        let volume = Double.pi * lengthM * midDiameterCm * midDiameterCm / VolumeConstant.huberDivisor
        return roundVolume(volume)
    }

    static func newton(
        topDiameterCm: Double,
        midDiameterCm: Double,
        buttDiameterCm: Double,
        lengthM: Double
    ) -> Double {
        let diameterSum = topDiameterCm * topDiameterCm
            + VolumeConstant.newtonMidCoefficient * midDiameterCm * midDiameterCm
            + buttDiameterCm * buttDiameterCm
        let volume = Double.pi * lengthM * diameterSum / VolumeConstant.newtonDivisor
        return roundVolume(volume)
    }

    static func hollow(
        outerDiameterCm: Double,
        innerDiameterCm: Double,
        lengthM: Double
    ) -> HollowCalculationResult {
        let outerVolume = standardCylinder(diameterCm: outerDiameterCm, lengthM: lengthM)
        let innerVolume = standardCylinder(diameterCm: innerDiameterCm, lengthM: lengthM)
        let netVolume = roundVolume(outerVolume - innerVolume)
        let equivalentDiameter = equivalentSolidDiameterCm(volumeM3: netVolume, lengthM: lengthM)
        return HollowCalculationResult(
            netVolumeM3: netVolume,
            equivalentSolidDiameterCm: equivalentDiameter
        )
    }

    private static func roundVolume(_ value: Double) -> Double {
        (value * VolumeConstant.precisionFactor).rounded() / VolumeConstant.precisionFactor
    }

    private static func equivalentSolidDiameterCm(volumeM3: Double, lengthM: Double) -> Int {
        let diameterSquared = volumeM3 * VolumeConstant.huberDivisor / (Double.pi * lengthM)
        let diameter = sqrt(diameterSquared)
        return Int(diameter.rounded())
    }
}

private enum VolumeConstant {
    static let diameterToRadiusM: Double = 200
    static let smalianDivisor: Double = 120_000
    static let huberDivisor: Double = 40_000
    static let newtonDivisor: Double = 240_000
    static let newtonMidCoefficient: Double = 4
    static let precisionFactor: Double = 1_000
}
