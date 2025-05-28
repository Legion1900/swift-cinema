struct ImageConfig {
    let baseUrl: String
    let maxPosterSize: String

    func fullPosterPath(for path: String?) -> String? {
        guard let path = path, !path.isEmpty else {
            return nil
        }
        return "\(baseUrl)\(maxPosterSize)\(path)"
    }
}

public class ConfigProvider: Loggable {

    static var tag = "ConfigProvider"

    private static let ORIGNAL_SIZE = "original"

    private let movieSercice: MovieServiceProtocol
    private let moviesStorage: MoviesStorage
    let logger: Logger

    public init(
        forMovieService service: MovieServiceProtocol, andStorage moviesStorage: MoviesStorage,
        withLogger logger: Logger
    ) {
        self.movieSercice = service
        self.logger = logger
        self.moviesStorage = moviesStorage
    }

    func getConfigs() async throws -> ImageConfig {
        if let config = try await getFromStorage() {
            log("Returning cached image config")
            return config
        } else {
            log("Fetching image config from service")
            return try await fetchFromServiceAndCache()
        }
    }

    private func getFromStorage() async throws -> ImageConfig? {
        guard let record = try await moviesStorage.getImageConfig() else {
            return nil
        }

        return ImageConfig(baseUrl: record.baseUrl, maxPosterSize: record.maxPosterSize)
    }

    private func fetchFromServiceAndCache() async throws -> ImageConfig {
        let response = try await movieSercice.getConfigs().images
        let config = getImageConfig(from: response)

        try await moviesStorage.update(
            imgConfig: ImageConfigRecord(
                baseUrl: config.baseUrl, maxPosterSize: config.maxPosterSize)
        )

        return config
    }

    private func getImageConfig(from response: ConfigurationImagesResponse) -> ImageConfig {
        let maxSize =
            response.posterSizes.contains(Self.ORIGNAL_SIZE)
            ? Self.ORIGNAL_SIZE : getMaxSize(from: response.posterSizes)
        return ImageConfig(baseUrl: response.secureBaseUrl, maxPosterSize: maxSize)
    }

    private func getMaxSize(from sizes: [String]) -> String {
        return sizes.filter { $0.hasPrefix("w") }
            .max { left, right in
                left < right
            } ?? sizes.last!
    }
}
