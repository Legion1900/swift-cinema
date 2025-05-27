package com.legion1900.swiftcore

import com.legion1900.swiftcore.network.TMDBMovieService
import com.legion1900.swiftcore.storage.MoviesStorage
import com.legion1900.swiftcore.utils.AndroidLogger
import com.readdle.codegen.anotation.SwiftBlock
import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference
import com.readdle.codegen.anotation.SwiftValue
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.flow.flow

@SwiftValue
enum class MoviePageState(val rawValue: Int) {
    LOADING(0),
    LOADED(1),
    CONNECTIVITY_ERROR(2),
    FAILURE(3);

    companion object {

        private val values = entries
            .associateBy { it.rawValue }

        @JvmStatic
        fun valueOf(rawValue: Int): MoviePageState {
            return values[rawValue]!!
        }
    }
}

@SwiftValue
data class MoviesPage(
    var state: MoviePageState = MoviePageState.LOADING,
    var page: Int = 0,
    var movies: ArrayList<PopularMovie> = ArrayList(),
    var totalPages: Int = 0,
    var totalResults: Int = 0
)

@SwiftValue
data class PopularMovie(
    var id: Int = 0,
    var title: String = "",
    var overview: String = "",
    var releaseDate: String = "",
    var posterPath: String? = null,
    var averageScore: Double? = null
)

@FunctionalInterface
@SwiftBlock("(MoviesPage) -> Void")
fun interface PopularMoviesCompletion {
    fun invoke(state: MoviesPage)
}

@SwiftReference
class MovieProvider private constructor() {

    private var nativePointer: Long = 0

    external fun release()

    @SwiftFunc("popularMovies(onPage:completion:)")
    external fun popularMovies(
        page: Int,
        @SwiftBlock completion: PopularMoviesCompletion
    )

    companion object {

        @JvmStatic
        @SwiftFunc("init(forMovieService:andConfigProvider:withStorage:andLogger:)")
        external fun init(service: TMDBMovieService, configProvider: ConfigProvider, moviesStorage: MoviesStorage, logger: AndroidLogger): MovieProvider
    }
}

fun MovieProvider.getPopularMovies(page: Int): Flow<MoviesPage> {
    return callbackFlow {
        popularMovies(page) { state ->
            trySend(state)
        }

        awaitClose()
    }
}
