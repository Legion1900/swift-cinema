package com.legion1900.swiftcinema.ui.theme

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.rememberLazyListState
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Card
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.rememberVectorPainter
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.tooling.preview.Preview
import androidx.compose.ui.unit.dp
import coil3.compose.AsyncImage
import coil3.request.ImageRequest
import coil3.request.crossfade
import com.legion1900.swiftcinema.LoadingState
import com.legion1900.swiftcinema.MoviesListViewModel
import com.legion1900.swiftcore.PopularMovie

@Composable
fun MoviesListScreen(
    viewModel: MoviesListViewModel,
    modifier: Modifier,
    onMovieClick: (Int) -> Unit,
) {
    val state = viewModel.state.collectAsState()

    MoviesListScreen(
        movies = state.value.movies.values.toList(),
        loadingState = state.value.loadingState,
        modifier,
        onMovieClick = onMovieClick,
    )
}

@Composable
private fun MoviesListScreen(
    movies: List<PopularMovie>,
    loadingState: LoadingState,
    modifier: Modifier,
    onMovieClick: (Int) -> Unit
) {
    val listState = rememberLazyListState()

    LazyColumn(modifier, state = listState, verticalArrangement = Arrangement.spacedBy(6.dp)) {
        items(movies.size) { index ->
            val movie = movies[index]
            MovieCard(
                movie = movie,
                onClick = { onMovieClick(movie.id) },
                modifier = Modifier.fillParentMaxWidth()
                    .padding(horizontal = 6.dp)
            )
        }
    }
}

@Preview
@Composable
private fun MoviesListScreenPreview() {
    val list = listOf(
        PopularMovie(
            id = 1,
            title = "Inception",
            overview = "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a CEO.",
            releaseDate = "2010-07-16",
            posterPath = "https://image.tmdb.org/t/p/w500/whatever.jpg",
            averageScore = 8.8
        ),
        PopularMovie(
            id = 2,
            title = "The Matrix",
            overview = "A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.",
            releaseDate = "1999-03-31",
            posterPath = "https://image.tmdb.org/t/p/w500/whatever2.jpg",
            averageScore = 8.7
        ),
        PopularMovie(
            id = 3,
            title = "Interstellar",
            overview = "A team of explorers travel through a wormhole in space in an attempt to ensure humanity's survival.",
            releaseDate = "2014-11-07",
            posterPath = "https://image.tmdb.org/t/p/w500/whatever3.jpg",
            averageScore = 8.6
        ),
        PopularMovie(
            id = 4,
            title = "The Dark Knight",
            overview = "When the menace known as the Joker emerges from his mysterious past, he wreaks havoc and chaos on the people of Gotham.",
            releaseDate = "2008-07-18",
            posterPath = "https://image.tmdb.org/t/p/w500/whatever4.jpg",
            averageScore = 9.0
        )
    )

    MoviesListScreen(
        movies = list,
        loadingState = LoadingState.LOADED,
        modifier = Modifier.fillMaxSize(),
        onMovieClick = {}
    )
}

@Composable
private fun MovieCard(
    movie: PopularMovie,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Card(modifier) {
        val spacingHeight = Modifier.height(10.dp)

        Column {
            val request = ImageRequest.Builder(LocalContext.current)
                .data(movie.posterPath)
                .crossfade(true)
                .build()
            AsyncImage(
                model = request,
                contentDescription = "Movie poster for ${movie.title}",
                contentScale = ContentScale.FillWidth,
                modifier = Modifier.height(500.dp)
            )



            Spacer(modifier = spacingHeight)

            val horizontalPadding = Modifier.padding(horizontal = 6.dp)

            Text(
                text = movie.title,
                modifier = horizontalPadding,
                style = MaterialTheme.typography.titleLarge
            )

            Row(modifier = horizontalPadding) {
                Icon(
                    painter = rememberVectorPainter(Icons.Filled.Star),
                    contentDescription = "Average score icon",
                    tint = Color.Yellow.copy(blue = .7f, green = .9f),
                )

                Spacer(modifier = Modifier.width(4.dp))

                Text(
                    text = movie.averageScore?.toString() ?: "N/A",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(4.dp))
        }
    }
}

@Preview
@Composable
private fun MovieCardPreview() {
    SwiftCinemaPreview {
        MovieCard(
            movie = PopularMovie(
                id = 1,
                title = "Inception",
                overview = "A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a CEO.",
                releaseDate = "2010-07-16",
                posterPath = "https://image.tmdb.org/t/p/w500/whatever.jpg",
                averageScore = 8.8
            ),
            onClick = {}
        )
    }
}

@Composable
private fun ErrorBanner(modifier: Modifier = Modifier) {
//    SnackbarData()
//    Snackbar()
}
