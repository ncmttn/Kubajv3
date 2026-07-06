import XCTest
@testable import Kubajv3

final class ForestryCalculatorTests: XCTestCase {
    private let volumeAccuracy = 0.0005

    func testStandardCylinderWithKnownValues() {
        let volume = ForestryCalculator.standardCylinder(diameterCm: 40, lengthM: 5)

        XCTAssertEqual(volume, 0.628, accuracy: volumeAccuracy)
    }

    func testStandardCylinderWithSingleDiameter() {
        let radiusM = 25.0 / 200.0
        let expected = (Double.pi * radiusM * radiusM * 3.0 * 1_000).rounded() / 1_000

        let volume = ForestryCalculator.standardCylinder(diameterCm: 25, lengthM: 3)

        XCTAssertEqual(volume, expected, accuracy: volumeAccuracy)
    }

    func testSmalianWithKnownValues() {
        let volume = ForestryCalculator.smalian(topDiameterCm: 28, buttDiameterCm: 32, lengthM: 4)

        XCTAssertEqual(volume, 0.283, accuracy: volumeAccuracy)
    }

    func testSmalianMatchesFormula() {
        let top = 24.0
        let butt = 36.0
        let length = 6.0
        let diameterSum = top * top + top * butt + butt * butt
        let expected = (Double.pi * length * diameterSum / 120_000 * 1_000).rounded() / 1_000

        let volume = ForestryCalculator.smalian(topDiameterCm: top, buttDiameterCm: butt, lengthM: length)

        XCTAssertEqual(volume, expected, accuracy: volumeAccuracy)
    }

    func testHuberWithKnownValues() {
        let volume = ForestryCalculator.huber(midDiameterCm: 30, lengthM: 4)

        XCTAssertEqual(volume, 0.283, accuracy: volumeAccuracy)
    }

    func testHuberMatchesFormula() {
        let mid = 22.0
        let length = 5.5
        let expected = (Double.pi * length * mid * mid / 40_000 * 1_000).rounded() / 1_000

        let volume = ForestryCalculator.huber(midDiameterCm: mid, lengthM: length)

        XCTAssertEqual(volume, expected, accuracy: volumeAccuracy)
    }

    func testNewtonWithKnownValues() {
        let volume = ForestryCalculator.newton(
            topDiameterCm: 26,
            midDiameterCm: 30,
            buttDiameterCm: 34,
            lengthM: 4
        )

        XCTAssertEqual(volume, 0.284, accuracy: volumeAccuracy)
    }

    func testNewtonMatchesFormula() {
        let top = 20.0
        let mid = 28.0
        let butt = 32.0
        let length = 4.5
        let diameterSum = top * top + 4 * mid * mid + butt * butt
        let expected = (Double.pi * length * diameterSum / 240_000 * 1_000).rounded() / 1_000

        let volume = ForestryCalculator.newton(
            topDiameterCm: top,
            midDiameterCm: mid,
            buttDiameterCm: butt,
            lengthM: length
        )

        XCTAssertEqual(volume, expected, accuracy: volumeAccuracy)
    }

    func testHollowWithKnownValues() {
        let result = ForestryCalculator.hollow(outerDiameterCm: 40, innerDiameterCm: 20, lengthM: 5)

        XCTAssertEqual(result.netVolumeM3, 0.471, accuracy: volumeAccuracy)
        XCTAssertEqual(result.equivalentSolidDiameterCm, 35)
    }

    func testHollowNetVolumeIsDifferenceOfCylinders() {
        let outer = ForestryCalculator.standardCylinder(diameterCm: 50, lengthM: 4)
        let inner = ForestryCalculator.standardCylinder(diameterCm: 30, lengthM: 4)
        let expectedNet = ((outer - inner) * 1_000).rounded() / 1_000

        let result = ForestryCalculator.hollow(outerDiameterCm: 50, innerDiameterCm: 30, lengthM: 4)

        XCTAssertEqual(result.netVolumeM3, expectedNet, accuracy: volumeAccuracy)
    }

    func testHollowEquivalentDiameterIsRoundedToNearestInteger() {
        let result = ForestryCalculator.hollow(outerDiameterCm: 45, innerDiameterCm: 15, lengthM: 6)
        let diameterSquared = result.netVolumeM3 * 40_000 / (Double.pi * 6)
        let rawDiameter = sqrt(diameterSquared)
        let expectedDiameter = Int(rawDiameter.rounded())

        XCTAssertEqual(result.equivalentSolidDiameterCm, expectedDiameter)
    }

    func testAllVolumeResultsUseThreeDecimalPrecision() {
        let volumes = [
            ForestryCalculator.standardCylinder(diameterCm: 33, lengthM: 2.7),
            ForestryCalculator.smalian(topDiameterCm: 27, buttDiameterCm: 31, lengthM: 3.3),
            ForestryCalculator.huber(midDiameterCm: 29, lengthM: 3.3),
            ForestryCalculator.newton(topDiameterCm: 25, midDiameterCm: 29, buttDiameterCm: 33, lengthM: 3.3),
            ForestryCalculator.hollow(outerDiameterCm: 38, innerDiameterCm: 18, lengthM: 3.3).netVolumeM3,
        ]

        for volume in volumes {
            let scaled = volume * 1_000
            XCTAssertEqual(scaled, scaled.rounded())
        }
    }
}
