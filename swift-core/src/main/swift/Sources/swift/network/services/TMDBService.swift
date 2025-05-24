public class TMDBMovieService: MovieServiceProtocol {
    private let networkClient: NetworkClient

    public init(_ networkClient: NetworkClient) {
        self.networkClient = networkClient
    }

    public func getPopularMovies(
        page: Int,
        completion: @escaping (Result<DiscoverMoviesResponse, RequestError>) -> Void
    ) {
        networkClient.execute(endpoint: "/3/discover/movie", method: .GET) {
            (response: DiscoverMoviesResponse?, error: RequestError?) in
            if let error = error {
                completion(.failure(error))
            } else if let response = response {
                completion(.success(response))
            } else {
                completion(.failure(RequestError.unknownError(reason: "Unknown error occurred")))
            }
        }
    }
}
