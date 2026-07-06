import Foundation
import Observation
import SwiftData

@Observable
final class GroupingViewModel {
    var selectedFolder: Folder?
    var sortOrder: LogSortOrder = .descending
    var records: [LogRecord] = []
    var isExportSettingsPresented = false
    var pendingExportKind: ExportKind?
    var exportFileName: String = ""
    var shareURL: URL?
    var isShareSheetPresented = false

    var groups: [LogGroup] {
        let grouped = LogGroupingEngine.group(records: records)
        return LogGroupingEngine.sort(grouped, order: sortOrder)
    }

    var exportRows: [GroupedExportRow] {
        groups.map { GroupedExportRow(group: $0) }
    }

    var canExport: Bool {
        !groups.isEmpty
    }

    var totalVolumeM3: Double {
        groups.reduce(0) { $0 + $1.totalVolumeM3 }
    }

    var totalLogsCount: Int {
        groups.reduce(0) { $0 + $1.totalQuantity }
    }

    var activeBatchCount: Int {
        groups.count
    }

    var averageDiameterCm: Double {
        let count = totalLogsCount
        guard count > 0 else { return 0 }
        let weighted = groups.reduce(0.0) { partial, group in
            partial + group.diameterCm * Double(group.totalQuantity)
        }
        return weighted / Double(count)
    }

    var diameterSections: [DiameterSection] {
        let grouped = Dictionary(grouping: groups) { $0.diameterCm }
        let diameters = grouped.keys.sorted {
            switch sortOrder {
            case .ascending:
                return $0 < $1
            case .descending:
                return $0 > $1
            }
        }
        return diameters.map { diameter in
            let sectionGroups = LogGroupingEngine.sort(grouped[diameter] ?? [], order: sortOrder)
            return DiameterSection(diameterCm: diameter, groups: sectionGroups)
        }
    }

    func refreshRecords() {
        guard let selectedFolder else {
            records = []
            return
        }
        records = selectedFolder.records
    }

    func toggleSortOrder() {
        sortOrder = sortOrder == .ascending ? .descending : .ascending
    }

    func increaseQuantity(for group: LogGroup, modelContext: ModelContext) {
        guard let target = group.records.max(by: { $0.createdAt < $1.createdAt }) else {
            return
        }
        target.quantity += 1
        persist(modelContext)
    }

    func decreaseQuantity(for group: LogGroup, modelContext: ModelContext) {
        guard let target = group.records.max(by: { $0.createdAt < $1.createdAt }) else {
            return
        }
        if target.quantity > 1 {
            target.quantity -= 1
        } else {
            modelContext.delete(target)
        }
        persist(modelContext)
    }

    func deleteGroup(_ group: LogGroup, modelContext: ModelContext) {
        for record in group.records {
            modelContext.delete(record)
        }
        persist(modelContext)
    }

    func beginExport(_ kind: ExportKind) {
        pendingExportKind = kind
        isExportSettingsPresented = true
    }

    func completeExport(metadata: ExportMetadata) {
        guard let kind = pendingExportKind else {
            return
        }

        let rows = exportRows
        let exportMetadata = metadata.optionalLines.isEmpty ? ReportHeaderPreferences.metadata : metadata
        let fileName = exportFileName
        pendingExportKind = nil
        isExportSettingsPresented = false

        switch kind {
        case .pdf:
            shareURL = PDFGenerator.temporaryFileURL(rows: rows, metadata: exportMetadata, fileName: fileName)
        case .csv:
            shareURL = CSVExporter.temporaryFileURL(rows: rows, fileName: fileName)
        }

        if shareURL != nil {
            isShareSheetPresented = true
        }
    }

    func dismissExportCancellation() {
        pendingExportKind = nil
    }

    func deleteFolder(_ folder: Folder, modelContext: ModelContext) {
        modelContext.delete(folder)
        try? modelContext.save()
        if selectedFolder?.persistentModelID == folder.persistentModelID {
            selectedFolder = nil
        }
        records = []
    }

    private func persist(_ modelContext: ModelContext) {
        try? modelContext.save()
        refreshRecords()
    }
}
