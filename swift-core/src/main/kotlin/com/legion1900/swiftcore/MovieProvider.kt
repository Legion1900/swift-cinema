package com.legion1900.swiftcore

import com.legion1900.swiftcore.network.TMDBMovieService
import com.readdle.codegen.anotation.SwiftBlock
import com.readdle.codegen.anotation.SwiftFunc
import com.readdle.codegen.anotation.SwiftReference
import com.readdle.codegen.anotation.SwiftValue

@SwiftValue
enum class MovieProviderError(val rawValue: Int) {
    NETWORK_ERROR(0),
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
class MovieProvider private constructor(){

    private var nativePointer: Long = 0

    external fun release()

    @SwiftFunc("popularMovies(onPage:completion:)")
    external fun popularMovies(
        page: Int,
        @SwiftBlock completion: PopularMoviesCompletion
    )

    companion object {

        @JvmStatic
        @SwiftFunc("init(forMovieService:)")
        external fun init(service: TMDBMovieService): MovieProvider
    }
}
