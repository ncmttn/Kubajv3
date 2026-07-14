import Foundation
import zlib

enum XLSXExporter {
    static func generate(rows: [GroupedExportRow]) -> Data {
        let sheetXML = buildSheetXML(rows: rows)
        let entries: [MinimalZipWriter.Entry] = [
            .init(path: "[Content_Types].xml", data: Data(contentTypesXML.utf8)),
            .init(path: "_rels/.rels", data: Data(rootRelsXML.utf8)),
            .init(path: "xl/workbook.xml", data: Data(workbookXML.utf8)),
            .init(path: "xl/_rels/workbook.xml.rels", data: Data(workbookRelsXML.utf8)),
            .init(path: "xl/worksheets/sheet1.xml", data: Data(sheetXML.utf8)),
        ]
        return MinimalZipWriter.archive(entries: entries)
    }

    static func temporaryFileURL(rows: [GroupedExportRow], fileName: String) -> URL? {
        let data = generate(rows: rows)
        let safeName = ExportFileNaming.sanitized(fileName)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(safeName).xlsx")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static let contentTypesXML = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
      <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
      <Default Extension="xml" ContentType="application/xml"/>
      <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
      <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
    </Types>
    """

    private static let rootRelsXML = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
      <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
    </Relationships>
    """

    private static let workbookXML = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main" xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
      <sheets>
        <sheet name="Kubaj" sheetId="1" r:id="rId1"/>
      </sheets>
    </workbook>
    """

    private static let workbookRelsXML = """
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
      <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
    </Relationships>
    """

    private static func buildSheetXML(rows: [GroupedExportRow]) -> String {
        var xml = """
        <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
          <sheetData>

        """

        xml += rowXML(
            rowIndex: 1,
            cells: [
                L10n.Export.csvColumnLength,
                L10n.Export.csvColumnQuantity,
                L10n.Export.csvColumnDiameter,
                L10n.Export.csvColumnVolume,
            ]
        )

        for (offset, row) in rows.enumerated() {
            xml += rowXML(
                rowIndex: offset + 2,
                cells: [
                    DisplayFormatting.length(row.lengthM),
                    String(row.quantity),
                    DisplayFormatting.diameter(row.diameterCm),
                    DisplayFormatting.volume(row.totalVolumeM3),
                ]
            )
        }

        let totalQuantity = rows.reduce(0) { $0 + $1.quantity }
        let totalVolume = rows.reduce(0.0) { $0 + $1.totalVolumeM3 }
        xml += rowXML(
            rowIndex: rows.count + 2,
            cells: [
                L10n.Export.totalRowLabel,
                String(totalQuantity),
                "",
                DisplayFormatting.volume(totalVolume),
            ]
        )

        xml += """
          </sheetData>
        </worksheet>
        """
        return xml
    }

    private static func rowXML(rowIndex: Int, cells: [String]) -> String {
        let columns = ["A", "B", "C", "D"]
        var row = "    <row r=\"\(rowIndex)\">\n"
        for (index, value) in cells.enumerated() {
            let cellRef = "\(columns[index])\(rowIndex)"
            row += cellXML(reference: cellRef, value: value)
        }
        row += "    </row>\n"
        return row
    }

    private static func cellXML(reference: String, value: String) -> String {
        "      <c r=\"\(reference)\" t=\"inlineStr\"><is><t>\(escapeXML(value))</t></is></c>\n"
    }

    private static func escapeXML(_ value: String) -> String {
        value
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&apos;")
    }
}

private enum MinimalZipWriter {
    struct Entry {
        let path: String
        let data: Data
    }

    static func archive(entries: [Entry]) -> Data {
        var localData = Data()
        var centralDirectory = Data()
        var offset: UInt32 = 0

        for entry in entries {
            let pathData = Data(entry.path.utf8)
            let crc = crc32(entry.data)
            let size = UInt32(entry.data.count)

            var localHeader = Data()
            localHeader.appendUInt32(0x0403_4B50)
            localHeader.appendUInt16(20)
            localHeader.appendUInt16(0)
            localHeader.appendUInt16(0)
            localHeader.appendUInt16(0)
            localHeader.appendUInt16(0)
            localHeader.appendUInt32(crc)
            localHeader.appendUInt32(size)
            localHeader.appendUInt32(size)
            localHeader.appendUInt16(UInt16(pathData.count))
            localHeader.appendUInt16(0)
            localHeader.append(pathData)

            centralDirectory.appendUInt32(0x0201_4B50)
            centralDirectory.appendUInt16(20)
            centralDirectory.appendUInt16(20)
            centralDirectory.appendUInt16(0)
            centralDirectory.appendUInt16(0)
            centralDirectory.appendUInt16(0)
            centralDirectory.appendUInt16(0)
            centralDirectory.appendUInt32(crc)
            centralDirectory.appendUInt32(size)
            centralDirectory.appendUInt32(size)
            centralDirectory.appendUInt16(UInt16(pathData.count))
            centralDirectory.appendUInt16(0)
            centralDirectory.appendUInt16(0)
            centralDirectory.appendUInt16(0)
            centralDirectory.appendUInt16(0)
            centralDirectory.appendUInt32(0)
            centralDirectory.appendUInt32(offset)
            centralDirectory.append(pathData)

            localData.append(localHeader)
            localData.append(entry.data)
            offset += UInt32(localHeader.count + entry.data.count)
        }

        var result = localData
        let centralDirectoryOffset = UInt32(result.count)
        result.append(centralDirectory)

        var endRecord = Data()
        endRecord.appendUInt32(0x0605_4B50)
        endRecord.appendUInt16(0)
        endRecord.appendUInt16(0)
        endRecord.appendUInt16(UInt16(entries.count))
        endRecord.appendUInt16(UInt16(entries.count))
        endRecord.appendUInt32(UInt32(centralDirectory.count))
        endRecord.appendUInt32(centralDirectoryOffset)
        endRecord.appendUInt16(0)
        result.append(endRecord)
        return result
    }

    private static func crc32(_ data: Data) -> UInt32 {
        data.withUnsafeBytes { buffer in
            guard let base = buffer.bindMemory(to: Bytef.self).baseAddress else {
                return 0
            }
            return UInt32(zlib.crc32(0, base, uInt(buffer.count)))
        }
    }
}

private extension Data {
    mutating func appendUInt16(_ value: UInt16) {
        var littleEndian = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndian) { append(contentsOf: $0) }
    }

    mutating func appendUInt32(_ value: UInt32) {
        var littleEndian = value.littleEndian
        Swift.withUnsafeBytes(of: &littleEndian) { append(contentsOf: $0) }
    }
}
