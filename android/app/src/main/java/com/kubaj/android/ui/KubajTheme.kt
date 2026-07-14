package com.kubaj.android.ui

import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import com.kubaj.android.data.AppTheme

val KubajPrimary = Color(0xFF0877BE)
val KubajGreen = Color(0xFF27875A)
val KubajDanger = Color(0xFFD64545)

private val LightColors = lightColorScheme(
    primary = KubajPrimary,
    secondary = KubajGreen,
    background = Color(0xFFF7F8FA),
    surface = Color.White,
    surfaceVariant = Color(0xFFEDEFF2),
    onBackground = Color(0xFF17191E),
    onSurface = Color(0xFF17191E),
    outlineVariant = Color(0xFFE2E5E9)
)

private val DarkColors = darkColorScheme(
    primary = Color(0xFF5DB5F2),
    secondary = Color(0xFF74D2A5),
    background = Color(0xFF0F1115),
    surface = Color(0xFF1C1F26),
    surfaceVariant = Color(0xFF30343E),
    onBackground = Color(0xFFF5F6F8),
    onSurface = Color(0xFFF5F6F8),
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
