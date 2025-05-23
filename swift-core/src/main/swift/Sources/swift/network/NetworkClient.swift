import FoundationNetworking
import Foundation

public protocol ApiKeyProvider {

    func getApiKey() -> String
}

public enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
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

    public var logger: Logger?

    public init(_ baseUrl: String,_ apiKeyProvider: ApiKeyProvider) {
        self.apiKeyProvider = apiKeyProvider
        self.baseUrl = baseUrl
    }

    public func testRequest() {
        guard let request = getRequest(fromEndpoint: "/3/discover/movie", method: .get) else {
            logger?.log("Failed to create request", withTag: NetworkClient.TAG)
            return
        }
        execute(request: request)
    }

    private func getRequest(fromEndpoint endpoint: String, method: HttpMethod, body: Data? = nil) -> URLRequest? {
        guard let url = URL(string: "\(baseUrl)\(endpoint)") else {
            logger?.log("Invalid URL", withTag: NetworkClient.TAG)
            return nil
        }
        return getRequest(url: url, method: method, body: body)
    }

    private func getRequest(url: URL, method: HttpMethod, body: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.addValue("Bearer \(apiKeyProvider.getApiKey())", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        if let body = body {
            request.httpBody = body
        }

        request.timeoutInterval = 30

        return request
    }

    private func execute(request: URLRequest) {
        logger?.log("About to send request: \(request.httpMethod ?? "unknown") to URL: \(request.url?.absoluteString ?? "nil URL") with headers \(request.allHTTPHeaderFields ?? [:])", withTag: NetworkClient.TAG)

        let task = urlSession.dataTask(with: request) { data, urlResponse, error in
            // Check error
            if let error = error {
                self.logger?.log("Error: \(error.localizedDescription) (code: \(error._code), domain: \(error._domain))", withTag: NetworkClient.TAG)
                return
            }

            // Type-cast the URLResponse to HTTPURLResponse to get more details
            if let httpResponse = urlResponse as? HTTPURLResponse {
                self.logger?.log("Got HTTP response: status code \(httpResponse.statusCode), headers: \(httpResponse.allHeaderFields)", withTag: NetworkClient.TAG)
            } else {
                self.logger?.log("Got non-HTTP response or nil response: \(String(describing: urlResponse))", withTag: NetworkClient.TAG)
            }
            
            // Check data specifically
            if let data = data {
                self.logger?.log("Received data: \(data.count) bytes", withTag: NetworkClient.TAG)
            } else {
                self.logger?.log("No data received (data is nil)", withTag: NetworkClient.TAG)
            }
            
            // Process data if we have it
            guard let data = data, data.count > 0 else {
                self.logger?.log("No data to process", withTag: NetworkClient.TAG)
                return
            }
            
            // Try to parse the data as string
            if let stringResponse = String(data: data, encoding: .utf8) {
                self.logger?.log("Success! Response: \(stringResponse)", withTag: NetworkClient.TAG)
            } else {
                self.logger?.log("Success, but could not parse response as UTF-8 string. Raw data: \(data as NSData)", withTag: NetworkClient.TAG)
            }
        }
    
        task.resume()

    }
}
