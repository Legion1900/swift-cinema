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
    case cannotGetImageConfig
}

public class MovieProvider: Loggable {

    static var tag = "MovieProvider"

    private let movieService: MovieServiceProtocol
    private let configProvider: ConfigProvider

    let logger: Logger

    public init(
        forMovieService service: MovieServiceProtocol,
        andConfigProvider configProvider: ConfigProvider,
        withLogger: Logger
    ) {
        self.movieService = service
        self.configProvider = configProvider
        self.logger = withLogger
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
        let moviesResponse = try await discoverMovies(onPage: page)
        let imgCinfigs = try await getImageConfig()

        return mapToPopularMovies(
            response: moviesResponse,
            withImageConfig: imgCinfigs
        )
    }

    private func discoverMovies(onPage page: Int) async throws -> DiscoverMoviesResponse {
        do {
            return try await movieService.getPopularMovies(page: page)
        } catch {
            throw MovieProviderError.networkRequestFailed
        }
    }

    private func getImageConfig() async throws -> ImageConfig {
        do {
            let response = try await configProvider.getConfigs()
            return ImageConfig(baseUrl: response.baseUrl, maxPosterSize: response.maxPosterSize)
        } catch {
            log(String(describing: error))
            throw MovieProviderError.cannotGetImageConfig
        }
    }

    private func mapToPopularMovies(
        response: DiscoverMoviesResponse,
        withImageConfig imageConfig: ImageConfig
    ) -> PopularMovies {
        return PopularMovies(
            page: response.page,
            movies: response.results.map { movie in
                PopularMovie(
                    id: movie.id,
                    title: movie.title,
                    overview: movie.overview,
                    releaseDate: movie.releaseDate,
                    posterPath: imageConfig.fullPosterPath(for: movie.posterPath),
                    averageScore: movie.averageScore
                )
            },
            totalPages: response.totalPages,
            totalResults: response.totalResults
        )
    }

    private func asyncToCallback<R>(
        _ completion: @escaping (R?, MovieProviderError?) -> Void,
        _ asyncFunction: @escaping () async throws -> R
    ) {
        Task {
            do {
                log("About to call async function in MovieProvider")
                let result = try await asyncFunction()
                completion(result, nil)
            } catch let error as MovieProviderError {
                log("Got known error \(error)")
                completion(nil, error)
            } catch {
                log("Unknown error type \(error)")
            }
        }
    }
}
