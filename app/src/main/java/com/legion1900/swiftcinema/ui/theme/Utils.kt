package com.legion1900.swiftcinema.ui.theme

import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import coil3.ColorImage
import coil3.compose.AsyncImagePreviewHandler
import coil3.compose.LocalAsyncImagePreviewHandler

@Composable
fun SwiftCinemaPreview(
    content: @Composable () -> Unit
) {
    val previewHandler = AsyncImagePreviewHandler {
        ColorImage(Color.Red.toArgb())
    }

    SwiftCinemaTheme {
        CompositionLocalProvider(LocalAsyncImagePreviewHandler provides previewHandler) {
            content()
        }
    }
}
