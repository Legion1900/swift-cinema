package com.legion1900.swiftcinema

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.legion1900.swiftcore.MoviePageState
import com.legion1900.swiftcore.MovieProvider
import com.legion1900.swiftcore.MoviesPage
import com.legion1900.swiftcore.PopularMovie
import com.legion1900.swiftcore.getPopularMovies
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.catch
import kotlinx.coroutines.flow.launchIn
import kotlinx.coroutines.flow.onEach

data class MoviesListState(
    val movies: Map<Int, PopularMovie> = LinkedHashMap(),
    val loadingState: LoadingState = LoadingState.LOADING,
    val currentPage: Int = 0,
    val totalResults: Int = 0,
)

enum class LoadingState {
    LOADING,
    LOADED,
    CONNECTIVITY_ERROR,
    UNKNOWN_ERROR
}

class MoviesListViewModel(
    private val movieProvider: MovieProvider,
) : ViewModel() {

    private val _state = MutableStateFlow(MoviesListState())

    val state: StateFlow<MoviesListState> = _state

    fun loadInitialState() {
        movieProvider.getPopularMovies(page = 1)
            .onEach { newPage ->
                _state.value = reduce(_state.value, newPage)
            }
            .catch { err ->
                Log.e("MoviesListViewModel", "Error loading movies", err)
                _state.value = _state.value.copy(
                    loadingState = LoadingState.UNKNOWN_ERROR
                )
            }
            .launchIn(viewModelScope)
    }

    private fun reduce(
        state: MoviesListState,
        newPage: MoviesPage
    ): MoviesListState {
        val newMovies = LinkedHashMap(state.movies)
        newPage.movies.forEach { movie ->
            newMovies[movie.id] = movie
        }

        return state.copy(
            currentPage = newPage.page,
            totalResults = newPage.totalResults,
            movies = LinkedHashMap(newMovies),
            loadingState = when (newPage.state) {
                MoviePageState.LOADING -> LoadingState.LOADING
                MoviePageState.LOADED -> LoadingState.LOADED
                MoviePageState.CONNECTIVITY_ERROR -> LoadingState.CONNECTIVITY_ERROR
                MoviePageState.FAILURE -> LoadingState.UNKNOWN_ERROR
            }
        )
    }
}
