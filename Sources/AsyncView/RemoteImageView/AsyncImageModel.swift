import Foundation
import Cache

final class AsyncImageModel: AsyncModel, ObservableObject {
        
    typealias Output = Data
    
    @Published
    var result: AsyncResult<Output> = .empty
     
    private let url: URL
    private let expiry: Expiry // cache
            
    init(url: URL, expiry: Expiry = .short) {
        self.url = url
        self.expiry = expiry
    }
    
    var asyncOperationBlock: AsyncOperation {
        return { [unowned self] in
            let downloader = await ImageDownloader(expiry: expiry)
            let data = try await downloader.image(from: url)
            let isValid = PortableImage(data: data) != nil
            if isValid {
                return data
            }
            throw ImageDataValidationError.invalid
        }
    }
}

enum ImageDataValidationError: Swift.Error {
    case invalid
}
