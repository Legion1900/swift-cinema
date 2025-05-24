public struct PopularMovies: Codable {
    let page: Int
    let movies: [PopularMovie]
    let totalPages: Int
    let totalResults: Int
}

public struct PopularMovie: Codable {
    let id: Int
    let title: String
    let overview: String
    let releaseDate: String
    let posterPath: String?
    let averageScore: Double?
}

public enum MovieProviderError: Int, Error, Codable {
    case networkRequestFailed
}

public class MovieProvider {

    private let movieService: MovieServiceProtocol

    public init(forMovieService service: MovieServiceProtocol) {
        self.movieService = service
    }

    public func popularMovies(
        onPage page: Int,
        completion: @escaping (PopularMovies?, MovieProviderError?) -> Void
    ) {
        movieService.getPopularMovies(page: page) { result in
            switch result {
            case .success(let response):
                let popularMovies = PopularMovies(
                    page: response.page,
                    movies: response.results.map { movie in
                        PopularMovie(
                            id: movie.id,
                            title: movie.title,
                            overview: movie.overview,
                            releaseDate: movie.releaseDate,
                            posterPath: movie.posterPath,
                            averageScore: movie.averageScore
                        )
                    },
                    totalPages: response.totalPages,
                    totalResults: response.totalResults
                )
                completion(popularMovies, nil)
            case .failure(_):
                completion(nil, .networkRequestFailed)
            }
        }
    }
}
