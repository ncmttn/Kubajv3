import Foundation
import Observation
import SwiftData

@Observable
final class HomeViewModel {
    var diameterInput = ""
    var lengthInput = ""
    var quantityInput = "1"
    var draftEntries: [DraftLogEntry] = []
    var isHollowSheetPresented = false
    var isFolderSelectionPresented = false

    var defaultCalculationMethod: CalculationMethod = .huber

    var sortedEntries: [DraftLogEntry] {
        draftEntries.sorted { $0.createdAt > $1.createdAt }
    }

    var canSave: Bool {
        !draftEntries.isEmpty
    }

    func addEntryFromInput() {
        guard
            let diameter = InputParser.double(from: diameterInput),
            let length = InputParser.double(from: lengthInput),
            let quantity = InputParser.int(from: quantityInput),
            diameter > 0,
            length > 0,
            quantity > 0
        else {
            return
        }

        let volume = volumeForStandardEntry(diameterCm: diameter, lengthM: length)
        appendEntry(
            diameterCm: diameter,
            lengthM: length,
            quantity: quantity,
            volumeM3: volume,
            calculationMethod: defaultCalculationMethod,
            isHollow: false
        )
        clearInputFields()
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
            calculationMethod: defaultCalculationMethod,
            isHollow: true
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
                createdAt: entry.createdAt,
                folder: folder
            )
            modelContext.insert(record)
        }

        try? modelContext.save()
        draftEntries.removeAll()
    }

    private func volumeForStandardEntry(diameterCm: Double, lengthM: Double) -> Double {
        switch defaultCalculationMethod {
        case .smalian, .ulker:
            ForestryCalculator.standardCylinder(diameterCm: diameterCm, lengthM: lengthM)
        case .huber:
            ForestryCalculator.huber(midDiameterCm: diameterCm, lengthM: lengthM)
        case .newton:
            ForestryCalculator.newton(
                topDiameterCm: diameterCm,
                midDiameterCm: diameterCm,
                buttDiameterCm: diameterCm,
                lengthM: lengthM
            )
        }
    }

    private func appendEntry(
        diameterCm: Double,
        lengthM: Double,
        quantity: Int,
        volumeM3: Double,
        calculationMethod: CalculationMethod,
        isHollow: Bool
    ) {
        let entry = DraftLogEntry(
            id: UUID(),
            diameterCm: diameterCm,
            lengthM: lengthM,
            quantity: quantity,
            volumeM3: volumeM3,
            calculationMethod: calculationMethod,
            isHollow: isHollow,
            createdAt: Date()
        )
        draftEntries.append(entry)
    }

    private func clearInputFields() {
        diameterInput = ""
        lengthInput = ""
        quantityInput = "1"
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
