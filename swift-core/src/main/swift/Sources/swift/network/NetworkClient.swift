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
public struct Empty: Codable {}

public enum RequestError: Error {
    case invalidUrl
    case requestFailed(code: Int, message: String)
    case responseParsingFailed(reason: String)
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

    public func testRequest() {
        guard let request = getRequest(fromEndpoint: "/3/discover/movie", method: .GET) else {
            logMessage("Failed to create request")
            return
        }
        // Explicitly use Empty for the response type when you don't expect a specific response
        execute(request: request, responseType: Empty.self)
    }

    // Helper method to make it easier to call execute with a specific response type
    private func execute<Response: Codable>(
        request: URLRequest, responseType: Response.Type,
        completion: ((Response?, RequestError?) -> Void)? = nil
    ) {
        execute(request: request, completion)
    }

    private func getRequest(fromEndpoint endpoint: String, method: HttpMethod, body: Data? = nil)
        -> URLRequest?
    {
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            logMessage("Invalid URL")
            return nil
        }
        return getRequest(url: url, method: method, body: body)
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

    private func execute<Response: Decodable>(
        request: URLRequest, _ completion: ((Response?, RequestError?) -> Void)? = nil
    ) {
        logMessage(
            "About to send request: \(request.httpMethod ?? "unknown") to URL: \(request.url?.absoluteString ?? "nil URL") with headers \(request.allHTTPHeaderFields ?? [:])"
        )

        let task = urlSession.dataTask(with: request) { data, urlResponse, error in
            // Check error
            if let error = error {
                let error = RequestError.unknownError(reason: String(describing: error))
                self.logError(error)
                completion?(nil, error)
                return
            }

            if let error = self.checkResponse(urlResponse) {
                self.logError(error)
                completion?(nil, error)
                return
            }

            let response = self.parseResponse(data, responseType: Response.self)
            switch response {
            case .success(let parsedResponse):
                self.logMessage("Request succeeded with response: \(parsedResponse)")
                completion?(parsedResponse, nil)
            case .failure(let error):
                self.logError(error)
                completion?(nil, error)
            }
        }

        task.resume()
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

    private func parseResponse<Response: Decodable>(_ data: Data?, responseType: Response.Type)
        -> Result<Response, RequestError>
    {
        do {
            let response = try decoder.decode(Response.self, from: data!)
            return .success(response)
        } catch {
            let plaintextDataContent =
                if let data = data {
                    String(data: data, encoding: .utf8) ?? "nil"
                } else {
                    "nil"
                }

            let reason =
                "Failed to parse response: \(error.localizedDescription). Data: \(String(describing: data)), \(plaintextDataContent)"
            return .failure(.responseParsingFailed(reason: reason))
        }
    }

    private func logMessage(_ message: String) {
        logger?.log(message, withTag: NetworkClient.TAG)
    }

    private func logError(_ error: RequestError) {
        logMessage(String(describing: error))
    }
}
