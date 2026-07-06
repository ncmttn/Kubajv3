import UIKit

enum PDFGenerator {
    static func generate(rows: [GroupedExportRow], metadata: ExportMetadata) -> Data? {
        let pageRect = CGRect(origin: .zero, size: PDFLayout.pageSize)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            var rowIndex = 0
            var pageNumber = 0

            while rowIndex < rows.count || pageNumber == 0 {
                context.beginPage()
                let cgContext = context.cgContext
                var cursorY = PDFLayout.topMargin

                if pageNumber == 0 {
                    cursorY = drawTitle(at: cursorY, in: pageRect)
                    cursorY = drawMetadata(metadata, at: cursorY, in: pageRect)
                    cursorY = drawTableHeader(at: cursorY, in: pageRect, context: cgContext)
                } else {
                    cursorY = drawTableHeader(at: cursorY, in: pageRect, context: cgContext)
                }

                let availableHeight = pageRect.height - PDFLayout.bottomMargin - cursorY
                let rowsPerPage = max(1, Int(availableHeight / PDFLayout.rowHeight))
                let endIndex = min(rowIndex + rowsPerPage, rows.count)

                for index in rowIndex..<endIndex {
                    let isAlternate = index.isMultiple(of: 2)
                    cursorY = drawRow(
                        rows[index],
                        at: cursorY,
                        in: pageRect,
                        context: cgContext,
                        isAlternate: isAlternate
                    )
                }

                rowIndex = endIndex
                pageNumber += 1

                if rowIndex >= rows.count && pageNumber > 0 {
                    break
                }
            }
        }
    }

    static func temporaryFileURL(rows: [GroupedExportRow], metadata: ExportMetadata) -> URL? {
        guard let data = generate(rows: rows, metadata: metadata) else {
            return nil
        }
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("kubaj-export-\(UUID().uuidString).pdf")
        do {
            try data.write(to: url)
            return url
        } catch {
            return nil
        }
    }

    private static func drawTitle(at y: CGFloat, in pageRect: CGRect) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: PDFLayout.titleFontSize),
        ]
        let title = L10n.Export.pdfTitle
        let size = title.size(withAttributes: attributes)
        let rect = CGRect(
            x: PDFLayout.horizontalMargin,
            y: y,
            width: pageRect.width - PDFLayout.horizontalMargin * 2,
            height: size.height
        )
        title.draw(in: rect, withAttributes: attributes)
        return y + size.height + PDFLayout.sectionSpacing
    }

    private static func drawMetadata(_ metadata: ExportMetadata, at y: CGFloat, in pageRect: CGRect) -> CGFloat {
        guard !metadata.optionalLines.isEmpty else {
            return y
        }

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: PDFLayout.metadataFontSize),
        ]
        var cursorY = y

        for line in metadata.optionalLines {
            let size = line.size(withAttributes: attributes)
            let rect = CGRect(
                x: PDFLayout.horizontalMargin,
                y: cursorY,
                width: pageRect.width - PDFLayout.horizontalMargin * 2,
                height: size.height
            )
            line.draw(in: rect, withAttributes: attributes)
            cursorY += size.height + PDFLayout.metadataLineSpacing
        }

        return cursorY + PDFLayout.sectionSpacing
    }

    private static func drawTableHeader(at y: CGFloat, in pageRect: CGRect, context: CGContext) -> CGFloat {
        let headers = [
            L10n.Export.pdfColumnDiameter,
            L10n.Export.pdfColumnLength,
            L10n.Export.pdfColumnQuantity,
            L10n.Export.pdfColumnVolume,
        ]
        let columnWidths = PDFLayout.columnWidths(pageWidth: pageRect.width)
        var x = PDFLayout.horizontalMargin

        context.setFillColor(UIColor.black.cgColor)
        context.fill(CGRect(
            x: PDFLayout.horizontalMargin,
            y: y,
            width: pageRect.width - PDFLayout.horizontalMargin * 2,
            height: PDFLayout.rowHeight
        ))

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: PDFLayout.tableFontSize),
            .foregroundColor: UIColor.white,
        ]

        for (index, header) in headers.enumerated() {
            let rect = CGRect(x: x, y: y + PDFLayout.cellPadding, width: columnWidths[index], height: PDFLayout.rowHeight)
            header.draw(in: rect, withAttributes: attributes)
            x += columnWidths[index]
        }

        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(PDFLayout.borderWidth)
        context.stroke(CGRect(
            x: PDFLayout.horizontalMargin,
            y: y,
            width: pageRect.width - PDFLayout.horizontalMargin * 2,
            height: PDFLayout.rowHeight
        ))

        return y + PDFLayout.rowHeight
    }

    private static func drawRow(
        _ row: GroupedExportRow,
        at y: CGFloat,
        in pageRect: CGRect,
        context: CGContext,
        isAlternate: Bool
    ) -> CGFloat {
        let columnWidths = PDFLayout.columnWidths(pageWidth: pageRect.width)
        let rowRect = CGRect(
            x: PDFLayout.horizontalMargin,
            y: y,
            width: pageRect.width - PDFLayout.horizontalMargin * 2,
            height: PDFLayout.rowHeight
        )

        if isAlternate {
            context.setFillColor(UIColor.systemGray6.cgColor)
            context.fill(rowRect)
        }

        let values = [
            DisplayFormatting.diameter(row.diameterCm),
            DisplayFormatting.length(row.lengthM),
            String(row.quantity),
            DisplayFormatting.volume(row.totalVolumeM3),
        ]

        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: PDFLayout.tableFontSize),
            .foregroundColor: UIColor.black,
        ]

        var x = PDFLayout.horizontalMargin
        for (index, value) in values.enumerated() {
            let rect = CGRect(x: x, y: y + PDFLayout.cellPadding, width: columnWidths[index], height: PDFLayout.rowHeight)
            value.draw(in: rect, withAttributes: attributes)
            x += columnWidths[index]
        }

        context.setStrokeColor(UIColor.lightGray.cgColor)
        context.setLineWidth(PDFLayout.borderWidth)
        context.stroke(rowRect)

        return y + PDFLayout.rowHeight
    }
}

private enum PDFLayout {
    static let pageSize = CGSize(width: 595.28, height: 841.89)
    static let horizontalMargin: CGFloat = 40
    static let topMargin: CGFloat = 48
    static let bottomMargin: CGFloat = 48
    static let rowHeight: CGFloat = 28
    static let cellPadding: CGFloat = 6
    static let borderWidth: CGFloat = 0.5
    static let sectionSpacing: CGFloat = 16
    static let metadataLineSpacing: CGFloat = 4
    static let titleFontSize: CGFloat = 22
    static let metadataFontSize: CGFloat = 12
    static let tableFontSize: CGFloat = 11

    static func columnWidths(pageWidth: CGFloat) -> [CGFloat] {
        let tableWidth = pageWidth - horizontalMargin * 2
        let diameter = tableWidth * 0.22
        let length = tableWidth * 0.22
        let quantity = tableWidth * 0.18
        let volume = tableWidth - diameter - length - quantity
        return [diameter, length, quantity, volume]
    }
}
