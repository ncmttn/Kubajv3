package com.kubaj.android.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.kubaj.android.data.AppTheme

val KubajPrimary = Color(0xFF0058BC)
val KubajPrimaryEnd = Color(0xFF0070EB)
val KubajGreen = Color(0xFF27875A)
val KubajDanger = Color(0xFFD64545)
val KubajTabInactive = Color(0xFF94A3B8)

private val LightColors = lightColorScheme(
    primary = KubajPrimary,
    secondary = KubajGreen,
    background = Color(0xFFF9F9F9),
    surface = Color(0xFFFFFFFF),
    surfaceVariant = Color(0xFFE2E2E2),
    onBackground = Color(0xFF1B1B1B),
    onSurface = Color(0xFF1B1B1B),
    onSurfaceVariant = Color(0xFF414755),
    outlineVariant = Color(0x1AC1C6D7)
)

private val DarkColors = darkColorScheme(
    primary = Color(0xFF5DB5F2),
    secondary = Color(0xFF74D2A5),
    background = Color(0xFF0F1115),
    surface = Color(0xFF1C1F26),
    surfaceVariant = Color(0xFF30343E),
    onBackground = Color(0xFFF5F6F8),
    onSurface = Color(0xFFF5F6F8),
    onSurfaceVariant = Color(0xFFAEB5C2),
    outlineVariant = Color(0x14FFFFFF)
)

@Composable
fun KubajTheme(theme: AppTheme, content: @Composable () -> Unit) {
    val dark = when (theme) {
        AppTheme.SYSTEM -> isSystemInDarkTheme()
        AppTheme.LIGHT -> false
        AppTheme.DARK -> true
    }
    MaterialTheme(
        colorScheme = if (dark) DarkColors else LightColors,
        content = content
    )
}
