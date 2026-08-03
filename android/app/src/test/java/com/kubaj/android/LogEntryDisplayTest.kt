package com.kubaj.android

import com.kubaj.android.domain.CalculationMethod
import com.kubaj.android.domain.DraftEntry
import com.kubaj.android.domain.LogEntryDisplay
import org.junit.Assert.assertEquals
import org.junit.Test

class LogEntryDisplayTest {
    @Test
    fun smalianShowsBothDiameters() {
        val entry = DraftEntry(
            id = "1",
            diameterCm = 21.0,
            lengthM = 3.0,
            quantity = 1,
            volumeM3 = 0.1,
            method = CalculationMethod.SMALIAN,
            topDiameterCm = 20.0,
            buttDiameterCm = 24.0
        )
        assertEquals("20-24", LogEntryDisplay.diameterLabel(entry))
    }

    @Test
    fun newtonShowsAllDiameters() {
        val entry = DraftEntry(
            id = "1",
            diameterCm = 22.0,
            lengthM = 3.0,
            quantity = 1,
            volumeM3 = 0.1,
            method = CalculationMethod.NEWTON,
            topDiameterCm = 20.0,
            midDiameterCm = 22.0,
            buttDiameterCm = 24.0
        )
        assertEquals("20-22-24", LogEntryDisplay.diameterLabel(entry))
    }

    @Test
    fun lumberShowsWidthAndThickness() {
        val entry = DraftEntry(
            id = "1",
            diameterCm = 20.0,
            lengthM = 4.0,
            quantity = 1,
            volumeM3 = 0.04,
            method = CalculationMethod.LUMBER,
            isLumber = true,
            lumberThicknessCm = 5.0
        )
        assertEquals("20×5", LogEntryDisplay.diameterLabel(entry))
    }
}
