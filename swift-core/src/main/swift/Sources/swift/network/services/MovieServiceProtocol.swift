public protocol MovieServiceProtocol: AnyObject {
    func getPopularMovies(
        page: Int,
        completion: @escaping (Result<DiscoverMoviesResponse, RequestError>) -> Void
    )
}
