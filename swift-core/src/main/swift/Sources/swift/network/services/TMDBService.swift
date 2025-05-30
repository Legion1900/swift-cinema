public class TMDBMovieService: MovieServiceProtocol {
    private let networkClient: NetworkClient

    public init(_ networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func getPopularMovies(
        page: Int
    ) async throws(RequestError) -> DiscoverMoviesResponse {
        try await networkClient.execute(endpoint: "/3/discover/movie", method: .GET)
    }

    public func getConfigs() async throws(RequestError) -> ConfigurationResponse {
        try await networkClient.execute(endpoint: "/3/configuration", method: .GET)
    }
}
