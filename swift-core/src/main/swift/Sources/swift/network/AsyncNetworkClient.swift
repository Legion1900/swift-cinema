extension NetworkClient {

    func execute<Response: Codable>(
        endpoint: String,
        method: HttpMethod
    ) async throws -> Response {
        return try await withCheckedThrowingContinuation { continuation in
            execute(endpoint: endpoint, method: method) {
                (response: Response?, error: RequestError?) in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let response = response {
                    continuation.resume(returning: response)
                }

            }
        }
    }
}
