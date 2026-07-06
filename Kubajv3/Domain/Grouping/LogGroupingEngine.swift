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

enum DiameterSortOrder: Sendable {
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

    static func sort(_ groups: [LogGroup], order: DiameterSortOrder) -> [LogGroup] {
        groups.sorted { lhs, rhs in
            switch order {
            case .ascending:
                if lhs.diameterCm == rhs.diameterCm {
                    return lhs.lengthM < rhs.lengthM
                }
                return lhs.diameterCm < rhs.diameterCm
            case .descending:
                if lhs.diameterCm == rhs.diameterCm {
                    return lhs.lengthM > rhs.lengthM
                }
                return lhs.diameterCm > rhs.diameterCm
            }
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
}
