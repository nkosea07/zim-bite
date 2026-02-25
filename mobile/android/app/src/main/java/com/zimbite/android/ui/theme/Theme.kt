package com.zimbite.android.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val ZimBiteOrange = Color(0xFFE85D04)
private val ZimBiteAmber = Color(0xFFFAA307)
private val ZimBiteDark = Color(0xFF1A1A1A)

private val LightColorScheme = lightColorScheme(
    primary = ZimBiteOrange,
    secondary = ZimBiteAmber,
    onPrimary = Color.White,
    background = Color(0xFFFFFBF7),
    surface = Color.White,
    onBackground = ZimBiteDark,
    onSurface = ZimBiteDark
)

@Composable
fun ZimBiteTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = LightColorScheme,
        content = content
    )
}
