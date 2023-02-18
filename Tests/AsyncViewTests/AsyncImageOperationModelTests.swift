import Foundation
import Dependencies
import XCTest
import Cache

@testable import AsyncView

final class AsyncImageOperationModelTests: XCTestCase {
    
    let url = URL(string: "asdf")!
    
    func testInvalidImageData() async throws {
        try await withDependencies {
            let data = Data(bytes: [2, 3], count: 2)
            $0.urlSession = URLSessionMock(data: data, didCall: {})
            $0.resourceCache = Cache<Resource>() // clears cache from previous tests
        } operation: {
            let model = await AsyncImageModel(url: url)
            await model.load()
            switch await model.result {
            case .failure(let error):
                let unwrapped = try XCTUnwrap(error as? ImageDataValidationError)
                XCTAssertEqual(unwrapped, .invalid)
            default:
                XCTFail()
            }
        }
    }
     
    func testValidImageData() async throws {
        try await withDependencies {
            let url = Bundle.module.url(forResource: "cats", withExtension: "jpg")!
            let data = try Data(contentsOf: url)
            $0.urlSession = URLSessionMock(data: data, didCall: {})
            $0.resourceCache = Cache<Resource>() // clears cache from previous tests
        } operation: {
            let model = await AsyncImageModel(url: url)
            await model.load()
            switch await model.result {
            case .success(let data):
                XCTAssertFalse(data.isEmpty)
            default:
                XCTFail()
            }
        }
    }
    
    func testCache() async throws {
        var count = 0
        try await withDependencies {
            let url = Bundle.module.url(forResource: "cats", withExtension: "jpg")!
            let data = try Data(contentsOf: url)
            $0.urlSession = URLSessionMock(data: data, didCall: { count += 1 })
            $0.resourceCache = Cache<Resource>() // clears cache from previous tests
        } operation: {
            let model = await AsyncImageModel(url: url)
            await model.load()
            await model.load()
            XCTAssert(count == 1)
        }
    }
}

struct URLSessionMock: DataTaskable {

    let data: Data
    
    let didCall: () -> Void
    
    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        didCall()
        return (data, URLResponse())
    }
}
