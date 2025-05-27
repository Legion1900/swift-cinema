package com.legion1900.swiftcinema

import android.os.Bundle
import android.util.Log
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.tooling.preview.Preview
import androidx.lifecycle.lifecycleScope
import com.legion1900.swiftcinema.ui.theme.SwiftCinemaTheme
import com.legion1900.swiftcore.MovieProvider
import com.legion1900.swiftcore.PopularMoviesCompletion
import com.legion1900.swiftcore.getPopularMovies
import com.legion1900.swiftcore.network.NetworkClient
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach
import org.koin.android.ext.android.get
import org.koin.androidx.viewmodel.ext.android.viewModel

class MainActivity : ComponentActivity() {

    private val viewModel by viewModel<MoviesListViewModel>()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        viewModel.loadInitialState()
        viewModel.state
            .onEach { state ->
                val movies = state.movies.values.map { it.title }
                Log.d("enigma", "Loaded movies on page ${state.currentPage} of total ${state.totalResults}, current state: ${state.loadingState} movies: $movies")
            }
            .launchIn(lifecycleScope)

        enableEdgeToEdge()
        setContent {
            SwiftCinemaTheme {
                Scaffold(modifier = Modifier.fillMaxSize()) { innerPadding ->
                    Greeting(
                        name = "Android",
                        modifier = Modifier.padding(innerPadding)
                    )
                }
            }
        }
    }
}

@Composable
fun Greeting(name: String, modifier: Modifier = Modifier) {
    Text(
        text = "Hello $name!",
        modifier = modifier
    )
}

@Preview(showBackground = true)
@Composable
fun GreetingPreview() {
    SwiftCinemaTheme {
        Greeting("Android")
    }
}