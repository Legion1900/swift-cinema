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
    let logger: Logger

    public init(forMovieService service: MovieServiceProtocol, logger: Logger) {
        self.movieSercice = service
        self.logger = logger
    }

    func getConfigs() async throws -> ImageConfig {
        let response = try await movieSercice.getConfigs().images
        return getImamapTogeConfig(from: response)
    }

    private func getImamapTogeConfig(from response: ConfigurationImagesResponse) -> ImageConfig {
        let maxSize =
            response.posterSizes.contains(Self.ORIGNAL_SIZE)
            ? Self.ORIGNAL_SIZE : getMaxSize(from: response.posterSizes)
        return ImageConfig(baseUrl: response.baseUrl, maxPosterSize: maxSize)
    }

    private func getMaxSize(from sizes: [String]) -> String {
        return sizes.filter { $0.hasPrefix("w") }
            .max { left, right in
                left < right
            } ?? sizes.last!
    }
}
