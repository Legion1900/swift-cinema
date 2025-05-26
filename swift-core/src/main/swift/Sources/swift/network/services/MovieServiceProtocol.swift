public protocol MovieServiceProtocol: AnyObject {
    func getPopularMovies(page: Int) async throws -> DiscoverMoviesResponse
    func getConfigs() async throws -> ConfigurationResponse
}
