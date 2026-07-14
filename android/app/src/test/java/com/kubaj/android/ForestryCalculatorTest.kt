package com.kubaj.android

import com.kubaj.android.domain.ForestryCalculator
import org.junit.Assert.assertEquals
import org.junit.Test

class ForestryCalculatorTest {
    @Test
    fun huberRoundsToThreeDecimals() {
        assertEquals(0.111, ForestryCalculator.huber(21.0, 3.2), 0.0001)
    }

    @Test
    fun hollowProducesEquivalentSolidDiameter() {
        val result = ForestryCalculator.hollow(40.0, 20.0, 3.0)
        assertEquals(35, result.equivalentDiameterCm)
        assertEquals(0.283, result.netVolumeM3, 0.0001)
    }

    @Test
    fun lumberUsesMetricConversion() {
        assertEquals(0.06, ForestryCalculator.lumber(20.0, 10.0, 3.0), 0.0001)
    }
}
