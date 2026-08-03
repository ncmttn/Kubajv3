package com.kubaj.android.domain

import kotlin.math.PI
import kotlin.math.round
import kotlin.math.sqrt

enum class CalculationMethod {
    HUBER,
    SMALIAN,
    NEWTON,
    LUMBER
}

data class HollowResult(
    val netVolumeM3: Double,
    val equivalentDiameterCm: Int
)

data class DraftEntry(
    val id: String,
    val diameterCm: Double,
    val lengthM: Double,
    val quantity: Int,
    val volumeM3: Double,
    val method: CalculationMethod,
    val isHollow: Boolean = false,
    val isLumber: Boolean = false,
    val topDiameterCm: Double? = null,
    val midDiameterCm: Double? = null,
    val buttDiameterCm: Double? = null,
    val lumberThicknessCm: Double? = null,
    val createdAt: Long = System.currentTimeMillis()
) {
    val totalVolumeM3: Double get() = volumeM3 * quantity
}

data class LogGroup(
    val id: String,
    val diameterCm: Double,
    val lengthM: Double,
    val totalQuantity: Int,
    val totalVolumeM3: Double,
    val records: List<com.kubaj.android.data.LogRecordEntity>
)

object ForestryCalculator {
    fun huber(midDiameterCm: Double, lengthM: Double): Double =
        roundVolume(PI * lengthM * midDiameterCm * midDiameterCm / 40_000.0)

    fun smalian(topDiameterCm: Double, buttDiameterCm: Double, lengthM: Double): Double {
        val sum = topDiameterCm * topDiameterCm +
            topDiameterCm * buttDiameterCm +
            buttDiameterCm * buttDiameterCm
        return roundVolume(PI * lengthM * sum / 120_000.0)
    }

    fun newton(
        topDiameterCm: Double,
        midDiameterCm: Double,
        buttDiameterCm: Double,
        lengthM: Double
    ): Double {
        val sum = topDiameterCm * topDiameterCm +
            4 * midDiameterCm * midDiameterCm +
            buttDiameterCm * buttDiameterCm
        return roundVolume(PI * lengthM * sum / 240_000.0)
    }

    fun lumber(widthCm: Double, thicknessCm: Double, lengthM: Double): Double =
        roundVolume((widthCm / 100.0) * (thicknessCm / 100.0) * lengthM)

    fun hollow(outerDiameterCm: Double, innerDiameterCm: Double, lengthM: Double): HollowResult {
        val outer = PI * (outerDiameterCm / 200).let { it * it } * lengthM
        val inner = PI * (innerDiameterCm / 200).let { it * it } * lengthM
        val volume = roundVolume(outer - inner)
        val diameter = sqrt(volume * 40_000 / (PI * lengthM)).roundToInt()
        return HollowResult(volume, diameter)
    }

    private fun Double.roundToInt(): Int = round(this).toInt()
    private fun roundVolume(value: Double): Double = round(value * 1_000) / 1_000
}

object LogGrouping {
    fun groupDrafts(drafts: List<DraftEntry>): List<LogGroup> =
        drafts
            .groupBy { it.lengthM to it.diameterCm }
            .map { (key, entries) ->
                val representative = entries.maxByOrNull { it.createdAt }!!
                LogGroup(
                    id = "${key.first}-${key.second}",
                    diameterCm = key.second,
                    lengthM = key.first,
                    totalQuantity = entries.sumOf { it.quantity },
                    totalVolumeM3 = entries.sumOf { it.totalVolumeM3 },
                    records = listOf(LogEntryDisplay.draftToRecord(representative))
                )
            }

    fun group(records: List<com.kubaj.android.data.LogRecordEntity>): List<LogGroup> =
        records
            .groupBy { it.lengthM to it.diameterCm }
            .map { (key, values) ->
                LogGroup(
                    id = "${key.first}-${key.second}",
                    diameterCm = key.second,
                    lengthM = key.first,
                    totalQuantity = values.sumOf { it.quantity },
                    totalVolumeM3 = values.sumOf { it.volumeM3 * it.quantity },
                    records = values
                )
            }

    fun sort(groups: List<LogGroup>, ascending: Boolean): List<LogGroup> =
        groups.sortedWith(
            compareBy<LogGroup> { if (ascending) it.lengthM else -it.lengthM }
                .thenBy { it.diameterCm }
        )

    fun lengthBands(lengths: List<Double>): List<Int> {
        var band = 0
        var previous: Double? = null
        return lengths.map { length ->
            if (previous != null && kotlin.math.abs(length - previous!!) > 0.0001) {
                band = 1 - band
            }
            previous = length
            band
        }
    }
}
