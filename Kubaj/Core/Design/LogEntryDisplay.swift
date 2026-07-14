import Foundation

enum LogEntryDisplay {
    static func diameterLabel(for entry: DraftLogEntry) -> String {
        if entry.isLumber, let thickness = entry.lumberThicknessCm {
            return L10n.Home.lumberDiameterFormat(
                width: entry.diameterCm,
                thickness: thickness
            )
        }
        if let top = entry.topDiameterCm, let butt = entry.buttDiameterCm, entry.calculationMethod == .smalian {
            return L10n.Home.smalianDiameterFormat(top: top, butt: butt)
        }
        return L10n.Home.diameterValue(entry.diameterCm)
    }

    static func diameterLabel(for record: LogRecord) -> String {
        if record.isLumberEntry, let thickness = record.lumberThicknessCm {
            return L10n.Home.lumberDiameterFormat(
                width: record.diameterCm,
                thickness: thickness
            )
        }
        if let top = record.topDiameterCm, let butt = record.buttDiameterCm, record.calculationMethod == .smalian {
            return L10n.Home.smalianDiameterFormat(top: top, butt: butt)
        }
        return L10n.Home.diameterValue(record.diameterCm)
    }

    static func diameterLabel(for group: LogGroup) -> String {
        guard let record = representativeRecord(in: group) else {
            return L10n.Home.diameterValue(group.diameterCm)
        }
        return diameterLabel(for: record)
    }

    static func isHollow(_ entry: DraftLogEntry) -> Bool {
        entry.isHollow
    }

    static func isLumber(_ entry: DraftLogEntry) -> Bool {
        entry.isLumber
    }

    static func isHollow(_ group: LogGroup) -> Bool {
        representativeRecord(in: group)?.isHollow ?? false
    }

    static func isLumber(_ group: LogGroup) -> Bool {
        representativeRecord(in: group)?.isLumberEntry ?? false
    }

    static func representativeRecord(in group: LogGroup) -> LogRecord? {
        group.records.max(by: { $0.createdAt < $1.createdAt })
    }
}
