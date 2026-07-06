import Foundation

enum CSVExporter {
    static func generate(rows: [GroupedExportRow]) -> Data {
        var lines: [String] = []
        lines.append(csvHeader())
        for row in rows {
            lines.append(csvLine(for: row))
        }
        lines.append(csvTotalLine(for: rows))
        let content = lines.joined(separator: "\n")
        var data = Data([0xEF, 0xBB, 0xBF])
        if let body = content.data(using: .utf8) {
            data.append(body)
        }
        return data
    }

    static func temporaryFileURL(rows: [GroupedExportRow], fileName: String) -> URL? {
        let data = generate(rows: rows)
        let safeName = ExportFileNaming.sanitized(fileName)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(safeName).csv")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static func csvHeader() -> String {
        [
            L10n.Export.csvColumnLength,
            L10n.Export.csvColumnQuantity,
            L10n.Export.csvColumnDiameter,
            L10n.Export.csvColumnVolume,
        ].joined(separator: ",")
    }

    private static func csvLine(for row: GroupedExportRow) -> String {
        [
            DisplayFormatting.length(row.lengthM),
            String(row.quantity),
            DisplayFormatting.diameter(row.diameterCm),
            DisplayFormatting.volume(row.totalVolumeM3),
        ].joined(separator: ",")
    }

    private static func csvTotalLine(for rows: [GroupedExportRow]) -> String {
        let totalQuantity = rows.reduce(0) { $0 + $1.quantity }
        let totalVolume = rows.reduce(0.0) { $0 + $1.totalVolumeM3 }
        return [
            L10n.Export.totalRowLabel,
            String(totalQuantity),
            "",
            DisplayFormatting.volume(totalVolume),
        ].joined(separator: ",")
    }
}
