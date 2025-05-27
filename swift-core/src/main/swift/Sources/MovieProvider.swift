public struct MoviesPage: Codable {
    let state: MoviePageState
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

public enum MoviePageState: Int, Codable {
    case loading
    case loaded
    case connectivityError
    case failure
}

public class MovieProvider: Loggable {

    static var tag = "MovieProvider"

    private let movieService: MovieServiceProtocol
    private let configProvider: ConfigProvider
    private let storage: MoviesStorage

    let logger: Logger

    public init(
        forMovieService service: MovieServiceProtocol,
        andConfigProvider configProvider: ConfigProvider,
        withStorage storage: MoviesStorage,
        andLogger: Logger
    ) {
        self.movieService = service
        self.configProvider = configProvider
        self.logger = andLogger
        self.storage = storage
    }

    public func popularMovies(
        onPage page: Int,
        completion: @escaping (MoviesPage) -> Void
    ) {
        Task {
            let initial = await self.getPaigeFromCache(onPage: page)
            completion(initial)
            let fresh = await self.getPageFromService(onPage: page, withCache: initial)
            completion(fresh)
        }
    }

    private func getPaigeFromCache(onPage page: Int) async -> MoviesPage {
        let limit = 20
        let offset = (page - 1) * limit
        let movies = await getMoviesFromCache(offset: offset, limit: limit)
        let totalCacheCount = await storage.getMoviesCount()
        let pageCount = totalCacheCount / limit + (totalCacheCount % limit > 0 ? 1 : 0)
        return MoviesPage(
            state: .loading, page: 1, movies: movies, totalPages: pageCount,
            totalResults: totalCacheCount)
    }

    private func getMoviesFromCache(offset: Int, limit: Int) async -> [PopularMovie] {
        do {
            let movieRecords = try await storage.getMovies(offset: offset, limit: limit)
            return movieRecords.map(mapToPopularMovies)
        } catch {
            log("Failed to fetch movies from cache: \(error)")
            return []
        }
    }

    private func getPageFromService(
        onPage page: Int,
        withCache cache: MoviesPage
    ) async -> MoviesPage {
        var popularMovies: [PopularMovie] = cache.movies
        var totalPages = cache.totalPages
        var totalResults = cache.totalResults
        let state: MoviePageState
        do {
            let (movies, pageCount, totalResultCount) = try await fetchMoviesAndCache(onPage: page)
            totalPages = pageCount
            totalResults = totalResultCount
            popularMovies = movies
            state = .loaded
        } catch is RequestError {
            log("Can't fetch movies from service due to connectivity")
            state = .connectivityError
        } catch {
            log("Failed to fetch movies from service: \(error)")
            state = .failure
        }

        return MoviesPage(
            state: state, page: page, movies: popularMovies,
            totalPages: totalPages, totalResults: totalResults
        )
    }

    private func fetchMoviesAndCache(onPage page: Int) async throws -> (
        [PopularMovie], totalPages: Int, totalResults: Int
    ) {
        let response = try await movieService.getPopularMovies(page: page)
        let imageConfig = try await getImageConfig()
        let popularMovies = response.results.map { movie in
            mapToPopularMovie(response: movie, withImageConfig: imageConfig)
        }
        try await updateCache(with: popularMovies)
        return (popularMovies, response.totalPages, response.totalResults)
    }

    private func updateCache(with movies: [PopularMovie]) async throws {
        let records = movies.map(getMovieRecord(from:))
        do {
            try await storage.addOrUpdate(movies: records)
        } catch {
            log("Failed to update cache with movies: \(error)")
            throw error
        }
    }

    private func getMovieRecord(from movie: PopularMovie) -> MovieRecord {
        MovieRecord(
            serviceId: movie.id,
            title: movie.title,
            overview: movie.overview,
            releaseDate: movie.releaseDate,
            posterPath: movie.posterPath,
            averageScore: movie.averageScore
        )
    }

    private func getImageConfig() async throws -> ImageConfig {
        let response = try await configProvider.getConfigs()
        return ImageConfig(baseUrl: response.baseUrl, maxPosterSize: response.maxPosterSize)
    }

    private func mapToPopularMovie(
        response: Movie,
        withImageConfig imageConfig: ImageConfig
    ) -> PopularMovie {
        PopularMovie(
            id: response.id,
            title: response.title,
            overview: response.overview,
            releaseDate: response.releaseDate,
            posterPath: imageConfig.fullPosterPath(for: response.posterPath),
            averageScore: response.averageScore
        )
    }

    private func mapToPopularMovies(
        recor: MovieRecord
    ) -> PopularMovie {
        return PopularMovie(
            id: recor.serviceId,
            title: recor.title,
            overview: recor.overview,
            releaseDate: recor.releaseDate,
            posterPath: recor.posterPath,
            averageScore: recor.averageScore
        )
    }
}
