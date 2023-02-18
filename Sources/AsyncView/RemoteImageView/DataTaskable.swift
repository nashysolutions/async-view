import Foundation

protocol DataTaskable {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}
