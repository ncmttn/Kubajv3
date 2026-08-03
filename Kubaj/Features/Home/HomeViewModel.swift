import Foundation
import Observation
import SwiftData

@Observable
final class HomeViewModel {
    static let defaultDiameter = "21"

    var diameterInput = defaultDiameter
    var topDiameterInput = defaultDiameter
    var buttDiameterInput = defaultDiameter
    var midDiameterInput = defaultDiameter
    var widthInput = defaultDiameter
    var thicknessInput = ""
    var lengthInput = ""
    var quantityInput = "1"
    var draftEntries: [DraftLogEntry] = []
    var isFolderSelectionPresented = false
    var focusedInputField: HomeInputField? = .diameter
    var shouldSelectAllOnDiameterFocus = false

    var preferences: AppPreferences?

    private var activeCalculationMethod: CalculationMethod {
        preferences?.defaultCalculationMethod ?? .huber
    }

    var sortedEntries: [DraftLogEntry] {
        draftEntries.sorted { $0.createdAt > $1.createdAt }
    }

    var canSave: Bool {
        !draftEntries.isEmpty
    }

    var inputFieldsForCurrentFormula: [HomeInputField] {
        switch activeCalculationMethod {
        case .huber:
            [.diameter, .length, .quantity]
        case .ulker:
            [.width, .thickness, .length, .quantity]
        case .smalian:
            [.topDiameter, .buttDiameter, .length, .quantity]
        case .newton:
            [.topDiameter, .buttDiameter, .midDiameter, .length, .quantity]
        }
    }

    var canCalculate: Bool {
        parsedInputValues() != nil
    }

    var totalVolumeM3: Double {
        draftEntries.reduce(0) { $0 + $1.totalVolumeM3 }
    }

    var totalLogsCount: Int {
        draftEntries.reduce(0) { $0 + $1.quantity }
    }

    func incrementDiameter() {
        let base = InputParser.double(from: diameterInput) ?? 21
        diameterInput = DisplayFormatting.diameter(base + 1)
    }

    func clearAllEntries() {
        draftEntries.removeAll()
    }

    func addEntryFromInput() {
        guard let values = parsedInputValues() else {
            return
        }

        appendEntry(
            diameterCm: values.displayDiameter,
            lengthM: values.length,
            quantity: values.quantity,
            volumeM3: values.volume,
            calculationMethod: activeCalculationMethod,
            isHollow: false,
            isLumber: values.isLumber,
            topDiameterCm: values.topDiameter,
            midDiameterCm: values.midDiameter,
            buttDiameterCm: values.buttDiameter,
            lumberThicknessCm: values.lumberThickness
        )
        resetInputFieldsAfterCalculate()
    }

    func addHollowEntry(
        outerDiameterCm: Double,
        innerDiameterCm: Double,
        lengthM: Double,
        quantity: Int
    ) {
        guard
            outerDiameterCm > innerDiameterCm,
            innerDiameterCm > 0,
            lengthM > 0,
            quantity > 0
        else {
            return
        }

        let result = ForestryCalculator.hollow(
            outerDiameterCm: outerDiameterCm,
            innerDiameterCm: innerDiameterCm,
            lengthM: lengthM
        )

        appendEntry(
            diameterCm: Double(result.equivalentSolidDiameterCm),
            lengthM: lengthM,
            quantity: quantity,
            volumeM3: result.netVolumeM3,
            calculationMethod: activeCalculationMethod,
            isHollow: true,
            isLumber: false
        )
    }

    func addEquivalentEntry(diameterCm: Int, lengthM: Double, quantity: Int) {
        guard diameterCm > 0, lengthM > 0, quantity > 0 else {
            return
        }

        let volume = ForestryCalculator.huber(
            midDiameterCm: Double(diameterCm),
            lengthM: lengthM
        )

        appendEntry(
            diameterCm: Double(diameterCm),
            lengthM: lengthM,
            quantity: quantity,
            volumeM3: volume,
            calculationMethod: activeCalculationMethod,
            isHollow: true,
            isLumber: false
        )
    }

    func deleteEntry(id: UUID) {
        draftEntries.removeAll { $0.id == id }
    }
    func increaseQuantity(id: UUID) {
        guard let index = draftEntries.firstIndex(where: { $0.id == id }) else {
            return
        }
        draftEntries[index].quantity += 1
    }

    func decreaseQuantity(id: UUID) {
        guard let index = draftEntries.firstIndex(where: { $0.id == id }) else {
            return
        }
        if draftEntries[index].quantity > 1 {
            draftEntries[index].quantity -= 1
        }
    }

    func saveEntries(to folder: Folder, modelContext: ModelContext) {
        for entry in draftEntries {
            let record = LogRecord(
                diameterCm: entry.diameterCm,
                lengthM: entry.lengthM,
                quantity: entry.quantity,
                volumeM3: entry.volumeM3,
                calculationMethod: entry.calculationMethod,
                isHollow: entry.isHollow,
                isLumber: entry.isLumber,
                topDiameterCm: entry.topDiameterCm,
                midDiameterCm: entry.midDiameterCm,
                buttDiameterCm: entry.buttDiameterCm,
                lumberThicknessCm: entry.lumberThicknessCm,
                createdAt: entry.createdAt,
                folder: folder
            )
            modelContext.insert(record)
        }

        try? modelContext.save()
        draftEntries.removeAll()
    }

    func focusFieldAfterCalculate() {
        shouldSelectAllOnDiameterFocus = true
        focusedInputField = primaryDiameterField
    }

    var primaryDiameterField: HomeInputField {
        switch activeCalculationMethod {
        case .smalian, .newton:
            .topDiameter
        case .huber:
            .diameter
        case .ulker:
            .width
        }
    }

    func nextField(after field: HomeInputField) -> HomeInputField? {
        let fields = inputFieldsForCurrentFormula
        guard let index = fields.firstIndex(of: field), index + 1 < fields.count else {
            return nil
        }
        return fields[index + 1]
    }

    private struct ParsedInputValues {
        let displayDiameter: Double
        let length: Double
        let quantity: Int
        let volume: Double
        let isLumber: Bool
        let topDiameter: Double?
        let midDiameter: Double?
        let buttDiameter: Double?
        let lumberThickness: Double?
    }

    private func parsedInputValues() -> ParsedInputValues? {
        guard
            let length = InputParser.double(from: lengthInput),
            let quantity = InputParser.int(from: quantityInput),
            length > 0,
            quantity > 0
        else {
            return nil
        }

        switch activeCalculationMethod {
        case .huber:
            guard let diameter = InputParser.double(from: diameterInput), diameter > 0 else {
                return nil
            }
            let volume = ForestryCalculator.huber(midDiameterCm: diameter, lengthM: length)
            return ParsedInputValues(
                displayDiameter: diameter,
                length: length,
                quantity: quantity,
                volume: volume,
                isLumber: false,
                topDiameter: nil,
                midDiameter: nil,
                buttDiameter: nil,
                lumberThickness: nil
            )

        case .ulker:
            guard
                let width = InputParser.double(from: widthInput),
                let thickness = InputParser.double(from: thicknessInput),
                width > 0,
                thickness > 0
            else {
                return nil
            }
            let volume = ForestryCalculator.lumber(
                widthCm: width,
                thicknessCm: thickness,
                lengthM: length
            )
            return ParsedInputValues(
                displayDiameter: width,
                length: length,
                quantity: quantity,
                volume: volume,
                isLumber: true,
                topDiameter: nil,
                midDiameter: nil,
                buttDiameter: nil,
                lumberThickness: thickness
            )

        case .smalian:
            guard
                let top = InputParser.double(from: topDiameterInput),
                let butt = InputParser.double(from: buttDiameterInput),
                top > 0,
                butt > 0
            else {
                return nil
            }
            let volume = ForestryCalculator.smalian(
                topDiameterCm: top,
                buttDiameterCm: butt,
                lengthM: length
            )
            return ParsedInputValues(
                displayDiameter: top,
                length: length,
                quantity: quantity,
                volume: volume,
                isLumber: false,
                topDiameter: top,
                midDiameter: nil,
                buttDiameter: butt,
                lumberThickness: nil
            )

        case .newton:
            guard
                let top = InputParser.double(from: topDiameterInput),
                let mid = InputParser.double(from: midDiameterInput),
                let butt = InputParser.double(from: buttDiameterInput),
                top > 0,
                mid > 0,
                butt > 0
            else {
                return nil
            }
            let volume = ForestryCalculator.newton(
                topDiameterCm: top,
                midDiameterCm: mid,
                buttDiameterCm: butt,
                lengthM: length
            )
            return ParsedInputValues(
                displayDiameter: mid,
                length: length,
                quantity: quantity,
                volume: volume,
                isLumber: false,
                topDiameter: top,
                midDiameter: mid,
                buttDiameter: butt,
                lumberThickness: nil
            )
        }
    }

    private func appendEntry(
        diameterCm: Double,
        lengthM: Double,
        quantity: Int,
        volumeM3: Double,
        calculationMethod: CalculationMethod,
        isHollow: Bool,
        isLumber: Bool,
        topDiameterCm: Double? = nil,
        midDiameterCm: Double? = nil,
        buttDiameterCm: Double? = nil,
        lumberThicknessCm: Double? = nil
    ) {
        let entry = DraftLogEntry(
            id: UUID(),
            diameterCm: diameterCm,
            lengthM: lengthM,
            quantity: quantity,
            volumeM3: volumeM3,
            calculationMethod: calculationMethod,
            isHollow: isHollow,
            isLumber: isLumber,
            topDiameterCm: topDiameterCm,
            midDiameterCm: midDiameterCm,
            buttDiameterCm: buttDiameterCm,
            lumberThicknessCm: lumberThicknessCm,
            createdAt: Date()
        )
        draftEntries.append(entry)
    }

    private func resetInputFieldsAfterCalculate() {
        quantityInput = "1"
        focusFieldAfterCalculate()
    }
}

private enum InputParser {
    static func double(from text: String) -> Double? {
        let normalized = text
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")
        return Double(normalized)
    }

    static func int(from text: String) -> Int? {
        let normalized = text.trimmingCharacters(in: .whitespacesAndNewlines)
        return Int(normalized)
    }
}
