package com.kubaj.android.export

import android.content.Context
import android.content.Intent
import android.graphics.Paint
import android.graphics.Typeface
import android.graphics.pdf.PdfDocument
import androidx.core.content.FileProvider
import com.kubaj.android.R
import com.kubaj.android.domain.LogEntryDisplay
import com.kubaj.android.domain.LogGroup
import com.kubaj.android.ui.diameterFormat
import com.kubaj.android.ui.lengthFormat
import com.kubaj.android.ui.volumeFormat
import java.io.File
import java.io.FileOutputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipOutputStream

data class ExportMetadata(val lines: List<String>)

object Exporters {
    fun createPdf(
        context: Context,
        fileName: String,
        groups: List<LogGroup>,
        metadata: ExportMetadata
    ): File {
        val directory = File(context.cacheDir, "exports").apply { mkdirs() }
        val file = File(directory, "${safeName(fileName)}.pdf")
        val document = PdfDocument()
        val width = 595
        val height = 842
        val margin = 42f
        val paint = Paint(Paint.ANTI_ALIAS_FLAG)
        var pageNumber = 1
        var page = document.startPage(PdfDocument.PageInfo.Builder(width, height, pageNumber).create())
        var canvas = page.canvas
        var y = 55f

        fun drawHeader() {
            paint.typeface = Typeface.DEFAULT_BOLD
            paint.textSize = 22f
            paint.color = android.graphics.Color.rgb(8, 119, 190)
            canvas.drawText("Kübaj", margin, y, paint)
            y += 30
            paint.color = android.graphics.Color.DKGRAY
            paint.textSize = 15f
            canvas.drawText(context.getString(R.string.calculations), margin, y, paint)
            y += 24
            paint.typeface = Typeface.DEFAULT
            paint.textSize = 10f
            metadata.lines.filter { it.isNotBlank() }.take(5).forEach {
                canvas.drawText(it, margin, y, paint)
                y += 15
            }
            y += 10
            paint.typeface = Typeface.DEFAULT_BOLD
            canvas.drawText(context.getString(R.string.table_length), margin, y, paint)
            canvas.drawText(context.getString(R.string.table_quantity), 150f, y, paint)
            canvas.drawText(context.getString(R.string.table_diameter), 250f, y, paint)
            canvas.drawText(context.getString(R.string.table_volume), 370f, y, paint)
            y += 18
            canvas.drawLine(margin, y, width - margin, y, paint)
            y += 17
        }

        drawHeader()
        paint.typeface = Typeface.DEFAULT
        paint.textSize = 10f
        groups.forEach { group ->
            if (y > height - 70) {
                document.finishPage(page)
                pageNumber++
                page = document.startPage(PdfDocument.PageInfo.Builder(width, height, pageNumber).create())
                canvas = page.canvas
                y = 55f
                drawHeader()
            }
            canvas.drawText(lengthFormat.format(group.lengthM), margin, y, paint)
            canvas.drawText(group.totalQuantity.toString(), 150f, y, paint)
            canvas.drawText(LogEntryDisplay.diameterLabel(group), 250f, y, paint)
            canvas.drawText(volumeFormat.format(group.totalVolumeM3), 370f, y, paint)
            y += 20
        }
        paint.typeface = Typeface.DEFAULT_BOLD
        y += 5
        canvas.drawLine(margin, y, width - margin, y, paint)
        y += 19
        canvas.drawText(context.getString(R.string.total), margin, y, paint)
        canvas.drawText(groups.sumOf { it.totalQuantity }.toString(), 150f, y, paint)
        canvas.drawText(volumeFormat.format(groups.sumOf { it.totalVolumeM3 }), 370f, y, paint)
        document.finishPage(page)
        FileOutputStream(file).use(document::writeTo)
        document.close()
        return file
    }

    fun createXlsx(context: Context, fileName: String, groups: List<LogGroup>): File {
        val directory = File(context.cacheDir, "exports").apply { mkdirs() }
        val file = File(directory, "${safeName(fileName)}.xlsx")
        ZipOutputStream(FileOutputStream(file)).use { zip ->
            zip.writeEntry("[Content_Types].xml", contentTypes)
            zip.writeEntry("_rels/.rels", rootRelationships)
            zip.writeEntry("xl/workbook.xml", workbook)
            zip.writeEntry("xl/_rels/workbook.xml.rels", workbookRelationships)
            zip.writeEntry("xl/worksheets/sheet1.xml", sheet(context, groups))
        }
        return file
    }

    fun copyToUri(context: Context, source: File, destination: android.net.Uri) {
        context.contentResolver.openOutputStream(destination)?.use { output ->
            source.inputStream().use { input -> input.copyTo(output) }
        } ?: error("Unable to open destination")
    }

    fun share(context: Context, file: File, mimeType: String) {
        val uri = FileProvider.getUriForFile(context, "${context.packageName}.fileprovider", file)
        val intent = Intent.createChooser(
            Intent(Intent.ACTION_SEND).apply {
                type = mimeType
                putExtra(Intent.EXTRA_STREAM, uri)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            },
            file.name
        )
        if (context !is android.app.Activity) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        context.startActivity(intent)
    }

    private fun sheet(context: Context, groups: List<LogGroup>): String {
        val rows = mutableListOf<List<String>>()
        rows += listOf(
            context.getString(R.string.table_length),
            context.getString(R.string.table_quantity),
            context.getString(R.string.table_diameter),
            context.getString(R.string.table_volume)
        )
        rows += groups.map {
            listOf(
                lengthFormat.format(it.lengthM),
                it.totalQuantity.toString(),
                LogEntryDisplay.diameterLabel(it),
                volumeFormat.format(it.totalVolumeM3)
            )
        }
        rows += listOf(
            context.getString(R.string.total),
            groups.sumOf { it.totalQuantity }.toString(),
            "",
            volumeFormat.format(groups.sumOf { it.totalVolumeM3 })
        )
        val columns = listOf("A", "B", "C", "D")
        val body = rows.mapIndexed { rowIndex, values ->
            val cells = values.mapIndexed { columnIndex, value ->
                "<c r=\"${columns[columnIndex]}${rowIndex + 1}\" t=\"inlineStr\"><is><t>${xml(value)}</t></is></c>"
            }.joinToString("")
            "<row r=\"${rowIndex + 1}\">$cells</row>"
        }.joinToString("")
        return """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
            <worksheet xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main">
            <sheetData>$body</sheetData></worksheet>""".trimIndent()
    }

    private fun ZipOutputStream.writeEntry(path: String, content: String) {
        putNextEntry(ZipEntry(path))
        write(content.toByteArray())
        closeEntry()
    }

    private fun xml(value: String): String = value
        .replace("&", "&amp;")
        .replace("<", "&lt;")
        .replace(">", "&gt;")
        .replace("\"", "&quot;")

    private fun safeName(value: String): String =
        value.trim().ifBlank { "kubaj-export" }.replace(Regex("""[\\/:*?"<>|\s]+"""), "_")

    private val contentTypes = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">
        <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>
        <Default Extension="xml" ContentType="application/xml"/>
        <Override PartName="/xl/workbook.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml"/>
        <Override PartName="/xl/worksheets/sheet1.xml" ContentType="application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml"/>
        </Types>""".trimIndent()

    private val rootRelationships = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument" Target="xl/workbook.xml"/>
        </Relationships>""".trimIndent()

    private val workbook = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <workbook xmlns="http://schemas.openxmlformats.org/spreadsheetml/2006/main"
        xmlns:r="http://schemas.openxmlformats.org/officeDocument/2006/relationships">
        <sheets><sheet name="Kubaj" sheetId="1" r:id="rId1"/></sheets></workbook>""".trimIndent()

    private val workbookRelationships = """<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
        <Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">
        <Relationship Id="rId1" Type="http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet" Target="worksheets/sheet1.xml"/>
        </Relationships>""".trimIndent()
}
