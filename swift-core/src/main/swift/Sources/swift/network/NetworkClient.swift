import Foundation

// Added to silence editor errors about unknown module. This module is separate only for non-Apple platforms.
#if canImport(FoundationNetworking)
    import FoundationNetworking
#endif

public protocol ApiKeyProvider {

    func getApiKey() -> String
}

public enum HttpMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

/// Simple empty type for API calls that don't return a response body
public struct Empty: Codable {

    static let noType: Empty? = nil
}

public enum RequestError: Error {
    case invalidUrl
    case requestFailed(code: Int, message: String)
    case serializationFailed(reason: String)
    case unknownError(reason: String)
}

public class NetworkClient {

    static let TAG = "NetworkClient"

    private let baseUrl: String
    private let apiKeyProvider: ApiKeyProvider

    private static var isCertificateSetUp = false

    public static func setupCertificates(_ certPath: String) {
        if !isCertificateSetUp {
            isCertificateSetUp = true
            setenv("URLSessionCertificateAuthorityInfoFile", certPath, 1)
        }
    }

    private lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 30
        return URLSession(configuration: configuration)
    }()

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    public var logger: Logger?

    public init(_ baseUrl: String, _ apiKeyProvider: ApiKeyProvider) {
        self.apiKeyProvider = apiKeyProvider
        self.baseUrl = baseUrl
    }

    public func execute<Response: Codable>(
        endpoint: String, method: HttpMethod = .GET
    ) async throws(RequestError) -> Response {
        try await execute(endpoint: endpoint, method: method, body: Empty.noType)
    }

    public func execute<Body: Codable, Response: Codable>(
        endpoint: String, method: HttpMethod = .GET, body: Body? = nil
    ) async throws(RequestError) -> Response {
        let result = serializeBody(body)
            .flatMap { body in
                getRequest(fromEndpoint: endpoint, method: .GET)
            }

        switch result {
        case .success(let request):
            return try await execute(request: request, withResponse: Response.self)
        case .failure(let error):
            logError(error, extraMessage: "Failed to create request for endpoint \(endpoint)")
            throw error
        }
    }

    private func serializeBody<Body: Codable>(_ body: Body?) -> Result<Data?, RequestError> {

        guard let body = body else {
            return .success(nil)
        }

        do {
            let body = try encoder.encode(body)
            return .success(body)
        } catch {
            return .failure(.serializationFailed(reason: String(describing: error)))
        }
    }

    private func getRequest(fromEndpoint endpoint: String, method: HttpMethod, body: Data? = nil)
        -> Result<URLRequest, RequestError>
    {
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            return .failure(.invalidUrl)
        }
        return .success(getRequest(url: url, method: method, body: body))
    }

    private func getRequest(url: URL, method: HttpMethod, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue(
            "Bearer \(apiKeyProvider.getApiKey())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
        }

        request.timeoutInterval = 30

        return request
    }

    private func execute<Response: Codable>(
        request: URLRequest,
        withResponse responseType: Response.Type
    ) async throws(RequestError) -> Response {
        let data = try await execute(request: request)
        do {
            return try parseResponse(data, asType: responseType)
        } catch {
            let error = RequestError.serializationFailed(
                reason:
                    "Failed to parse response for request \(request): \(error.localizedDescription)"
            )
            logError(error)
            throw error
        }
    }

    private func execute(request: URLRequest) async throws(RequestError) -> Data {
        do {
            let (data, response) = try await urlSession.data(for: request)
            if let error = checkResponse(response) {
                logError(error)
                throw error
            }
            return data
        } catch {
            throw RequestError.unknownError(reason: String(describing: error))
        }
    }

    private func checkResponse(_ response: URLResponse?) -> RequestError? {
        guard let httpResponse = response as? HTTPURLResponse else {
            return .unknownError(
                reason:
                    "Response is not of type HTTPURLResponse or nil: \(String(describing: response))"
            )
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            return .requestFailed(
                code: httpResponse.statusCode,
                message: "Request failed with status code \(httpResponse.statusCode)")
        }

        return nil
    }

    private func parseResponse<Response: Codable>(_ data: Data?, asType responseType: Response.Type)
        throws -> Response
    {
        do {
            let response = try decoder.decode(Response.self, from: data!)
            return response
        } catch {
            let plaintextDataContent =
                if let data = data {
                    String(data: data, encoding: .utf8) ?? "nil"
                } else {
                    "nil"
                }

            let reason =
                "Failed to parse response: \(error.localizedDescription). Data: \(String(describing: data)), \(plaintextDataContent)"
            throw RequestError.serializationFailed(reason: reason)
        }
    }

    private func logMessage(_ message: String) {
        logger?.log(message, withTag: NetworkClient.TAG)
    }

    private func logError(_ error: RequestError, extraMessage: String? = nil) {
        let errDescription = String(describing: error)
        let message = extraMessage.map { "\($0): \(errDescription)" } ?? errDescription
        logMessage(message)
    }
}
