import Foundation
import SwiftData

struct GroupingKey: Hashable, Sendable {
    let diameterCm: Double
    let lengthM: Double

    static func make(diameterCm: Double, lengthM: Double) -> GroupingKey {
        GroupingKey(diameterCm: diameterCm, lengthM: lengthM)
    }
}

struct DiameterSection: Identifiable, Equatable {
    let diameterCm: Double
    let groups: [LogGroup]

    var id: String {
        "\(diameterCm)"
    }

    var totalLogs: Int {
        groups.reduce(0) { $0 + $1.totalQuantity }
    }

    var totalVolumeM3: Double {
        groups.reduce(0) { $0 + $1.totalVolumeM3 }
    }
}

struct LogGroup: Identifiable, Equatable {
    let key: GroupingKey
    let records: [LogRecord]

    var id: String {
        "\(key.diameterCm)-\(key.lengthM)"
    }

    var diameterCm: Double { key.diameterCm }
    var lengthM: Double { key.lengthM }

    var totalQuantity: Int {
        records.reduce(0) { $0 + $1.quantity }
    }

    var totalVolumeM3: Double {
        records.reduce(0) { partial, record in
            partial + record.volumeM3 * Double(record.quantity)
        }
    }

    static func == (lhs: LogGroup, rhs: LogGroup) -> Bool {
        lhs.id == rhs.id && lhs.totalQuantity == rhs.totalQuantity && lhs.totalVolumeM3 == rhs.totalVolumeM3
    }
}

enum LogSortOrder: Sendable {
    case ascending
    case descending
}

struct LogGroupingEngine {
    static func group(records: [LogRecord]) -> [LogGroup] {
        let grouped = Dictionary(grouping: records) { record in
            GroupingKey.make(diameterCm: record.diameterCm, lengthM: record.lengthM)
        }

        return grouped.map { key, records in
            LogGroup(key: key, records: records)
        }
    }

    static func sort(_ groups: [LogGroup], order: LogSortOrder) -> [LogGroup] {
        groups.sorted { lhs, rhs in
            if lhs.lengthM != rhs.lengthM {
                switch order {
                case .ascending:
                    return lhs.lengthM < rhs.lengthM
                case .descending:
                    return lhs.lengthM > rhs.lengthM
                }
            }
            return lhs.diameterCm < rhs.diameterCm
        }
    }
}

enum FolderRecordCollector {
    static func collect(from folder: Folder) -> [LogRecord] {
        var result = folder.records
        for subfolder in folder.subFolders {
            result.append(contentsOf: collect(from: subfolder))
        }
        return result
    }

    static func folderOptions(from roots: [Folder]) -> [(folder: Folder, path: String)] {
        roots.flatMap { folderPathEntries(from: $0, prefix: "") }
    }

    private static func folderPathEntries(from folder: Folder, prefix: String) -> [(Folder, String)] {
        let path = prefix.isEmpty ? folder.name : "\(prefix) / \(folder.name)"
        var entries: [(Folder, String)] = []

        if !folder.records.isEmpty {
            entries.append((folder, path))
        }

        let sortedSubfolders = folder.subFolders.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        for subfolder in sortedSubfolders {
            entries.append(contentsOf: folderPathEntries(from: subfolder, prefix: path))
        }
        return entries
    }
}
