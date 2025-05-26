package com.legion1900.swiftcore

import com.legion1900.swiftcore.network.TMDBMovieService
import com.legion1900.swiftcore.utils.AndroidLogger
import com.readdle.codegen.anotation.SwiftBlock
import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference
import com.readdle.codegen.anotation.SwiftValue

@SwiftValue
enum class MovieProviderError(val rawValue: Int) {
    NETWORK_ERROR(0),
    CANNOT_GET_IMAGE_CONFIG(1);

    companion object {

        private val values = entries
            .associateBy { it.rawValue }

        @Suppress("unused")
        @JvmStatic
        fun valueOf(rawValue: Int): MovieProviderError {
            return values[rawValue]!!
        }
    }
}

@SwiftValue
data class PopularMovies(
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
@SwiftBlock("(PopularMovies?, MovieProviderError?) -> Void")
fun interface PopularMoviesCompletion {
    fun invoke(result: PopularMovies?, error: MovieProviderError?)
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
        @SwiftFunc("init(forMovieService:andConfigProvider:withLogger:)")
        external fun init(service: TMDBMovieService, configProvider: ConfigProvider, logger: AndroidLogger): MovieProvider
    }
}
