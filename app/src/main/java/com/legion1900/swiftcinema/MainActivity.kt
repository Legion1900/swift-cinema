package com.legion1900.swiftcinema

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.lifecycle.lifecycleScope
import coil3.ImageLoader
import coil3.compose.setSingletonImageLoaderFactory
import coil3.util.DebugLogger
import com.legion1900.swiftcinema.ui.theme.MoviesListScreen
import com.legion1900.swiftcinema.ui.theme.SwiftCinemaTheme
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import org.koin.androidx.viewmodel.ext.android.viewModel

class MainActivity : ComponentActivity() {

    private val viewModel by viewModel<MoviesListViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        viewModel.loadInitialState()
        viewModel.state
            .onEach { state ->
                val movies = state.movies.values.map { it.title }
                Log.d(
                    "enigma",
                    "Loaded movies on page ${state.currentPage} of total ${state.totalResults}, current state: ${state.loadingState} movies: $movies"
                )
            }
            .launchIn(lifecycleScope)

        enableEdgeToEdge()
        setContent {
            setupCoilImageLoader()
            SwiftCinemaTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    MoviesListScreen(viewModel, Modifier.padding(innerPadding)) {}
                }
            }
        }
    }

    @Composable
    private fun setupCoilImageLoader() {
        setSingletonImageLoaderFactory { context ->
            ImageLoader.Builder(context)
                .logger(DebugLogger())
                .build()
        }
    }
}
