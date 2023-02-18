import Foundation
import Cache
import Dependencies

// We need to cache items with an expiry date. These items
// have image data that are associated with a URL. To protect
// against reentrancy we keep Tasks in a collection named `idempotency`
// and these tasks cannot be cached. So we have a workaround here for that.
actor ImageDownloader {
    
    @Dependency(\.resourceCache) var resourceCache
    @Dependency(\.urlSession) var urlSession
    
    let expiry: Expiry
    
    init(expiry: Expiry) async {
        self.expiry = expiry
    }
    
    private var idempotency: [URL: Entry] = [:]
    
    func image(from url: URL) async throws -> Data {
        
        if let data = try await cachedData(for: url) {
            return data
        }
        
        let task = Task {
            let (data, _) = try await urlSession.data(for: .init(url: url))
            return Resource(id: url, data: data)
        }
        
        idempotency[url] = .inProgress(task)
        
        return try await complete(task, url)
    }
    
    private func cachedData(for url: URL) async throws -> Data? {
        
        if let entry = idempotency[url] {
            switch entry {
            case .inProgress(let task):
                return try await complete(task, url)
            case .ready(let resource):
                return lifetimeCachedData(for: resource.id)
            }
        }
        
        return lifetimeCachedData(for: url)
    }
    
    private func lifetimeCachedData(for url: URL) -> Data? {
        switch resourceCache.resource(for: url) {
        case .some(let resource):
            return resource.data
        case .none:
            idempotency[url] = nil
            return nil
        }
    }
    
    private func complete(_ task: Task<Resource, Error>, _ url: URL) async throws -> Data {
        do {
            let resource = try await task.value
            resourceCache.stash(resource, duration: .short)
            idempotency[url] = .ready(resource)
            return resource.data
        } catch {
            idempotency[url] = nil
            if let data = lifetimeCachedData(for: url) {
                return data
            }
            throw error
        }
    }
}

private enum Entry {
    case inProgress(Task<Resource, Error>)
    case ready(Resource)
}
