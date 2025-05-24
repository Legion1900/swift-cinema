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
import com.legion1900.swiftcinema.ui.theme.SwiftCinemaTheme
import com.legion1900.swiftcore.MovieProvider
import com.legion1900.swiftcore.PopularMoviesCompletion
import com.legion1900.swiftcore.network.NetworkClient
import org.koin.android.ext.android.get

class MainActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        val provider = get<MovieProvider>()

        provider.popularMovies(0) { movies, error ->
            if (error != null) {
                Log.e("MainActivity", "Error fetching popular movies: $error")
            } else {
                Log.d("MainActivity", "Fetched popular movies: $movies")
            }
        }

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