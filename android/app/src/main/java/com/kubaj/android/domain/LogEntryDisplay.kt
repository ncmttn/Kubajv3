package com.kubaj.android.domain

import com.kubaj.android.data.LogRecordEntity
import java.text.DecimalFormat

private val diameterFormat = DecimalFormat("0")

object LogEntryDisplay {
    fun diameterLabel(entry: DraftEntry): String = label(
        method = entry.method,
        diameterCm = entry.diameterCm,
        isLumber = entry.isLumber,
        topDiameterCm = entry.topDiameterCm,
        midDiameterCm = entry.midDiameterCm,
        buttDiameterCm = entry.buttDiameterCm,
        lumberThicknessCm = entry.lumberThicknessCm
    )

    fun diameterLabel(record: LogRecordEntity): String = label(
        method = runCatching { CalculationMethod.valueOf(record.calculationMethod) }.getOrNull(),
        diameterCm = record.diameterCm,
        isLumber = record.isLumber,
        topDiameterCm = record.topDiameterCm,
        midDiameterCm = record.midDiameterCm,
        buttDiameterCm = record.buttDiameterCm,
        lumberThicknessCm = record.lumberThicknessCm
    )

    fun diameterLabel(group: LogGroup): String {
        val record = group.records.maxByOrNull { it.createdAt }
        return if (record != null) diameterLabel(record) else fmt(group.diameterCm)
    }

    fun draftToRecord(entry: DraftEntry): LogRecordEntity =
        LogRecordEntity(
            folderId = 0,
            diameterCm = entry.diameterCm,
            lengthM = entry.lengthM,
            quantity = entry.quantity,
            volumeM3 = entry.volumeM3,
            calculationMethod = entry.method.name,
            isHollow = entry.isHollow,
            isLumber = entry.isLumber,
            topDiameterCm = entry.topDiameterCm,
            midDiameterCm = entry.midDiameterCm,
            buttDiameterCm = entry.buttDiameterCm,
            lumberThicknessCm = entry.lumberThicknessCm,
            createdAt = entry.createdAt
        )

    private fun label(
        method: CalculationMethod?,
        diameterCm: Double,
        isLumber: Boolean,
        topDiameterCm: Double?,
        midDiameterCm: Double?,
        buttDiameterCm: Double?,
        lumberThicknessCm: Double?
    ): String {
        if (isLumber && lumberThicknessCm != null) {
            return "${fmt(diameterCm)}×${fmt(lumberThicknessCm)}"
        }
        if (method == CalculationMethod.NEWTON &&
            topDiameterCm != null &&
            midDiameterCm != null &&
            buttDiameterCm != null
        ) {
            return "${fmt(topDiameterCm)}-${fmt(midDiameterCm)}-${fmt(buttDiameterCm)}"
        }
        if (method == CalculationMethod.SMALIAN &&
            topDiameterCm != null &&
            buttDiameterCm != null
        ) {
            return "${fmt(topDiameterCm)}-${fmt(buttDiameterCm)}"
        }
        return fmt(diameterCm)
    }

    private fun fmt(value: Double): String = diameterFormat.format(value)
}
