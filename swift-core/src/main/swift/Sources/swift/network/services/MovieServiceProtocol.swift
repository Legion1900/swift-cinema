public protocol MovieServiceProtocol: AnyObject {
    func getPopularMovies(page: Int) async throws(RequestError) -> DiscoverMoviesResponse
    func getConfigs() async throws(RequestError) -> ConfigurationResponse
}
