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
    private let logger: Logger

    public init(forMovieService service: MovieServiceProtocol, logger: Logger) {
        self.movieService = service
        self.logger = logger
    }

    public func popularMovies(
        onPage page: Int,
        completion: @escaping (PopularMovies?, MovieProviderError?) -> Void
    ) {
        asyncToCallback(completion) {
            try await self.getPopularMovies(page)
        }
    }

    private func getPopularMovies(
        _ page: Int
    ) async throws -> PopularMovies {
        do {
            let response = try await movieService.getPopularMovies(page: page)
            return PopularMovies(
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
        } catch {
            throw MovieProviderError.networkRequestFailed
        }
    }

    private func asyncToCallback<R>(
        _ completion: @escaping (R?, MovieProviderError?) -> Void,
        _ asyncFunction: @escaping () async throws -> R
    ) {
        Task {
            do {
                logger.log("About to call async function in MovieProvider", withTag: "enigma")
                let result = try await asyncFunction()
                completion(result, nil)
            } catch let error as MovieProviderError {
                logger.log("Got known error \(error)", withTag: "enigma")
                completion(nil, error)
            } catch {
                logger.log("Unknown error type \(error)", withTag: "enigma")
            }
        }
    }
}
