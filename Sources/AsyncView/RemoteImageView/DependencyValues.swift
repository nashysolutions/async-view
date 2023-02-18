#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

import Dependencies
import Cache

struct CacheDependencyKey: DependencyKey {
    static let liveValue = Cache<Resource>(maxSize: 100)
}

extension DependencyValues {
    
    var resourceCache: Cache<Resource> {
        get { self[CacheDependencyKey.self] }
        set { self[CacheDependencyKey.self] = newValue }
    }
}

extension URLSession: DataTaskable {}

struct SessionDependencyKey: DependencyKey {
    static let liveValue: DataTaskable = URLSession.shared
}

extension DependencyValues {
    
    var urlSession: DataTaskable {
        get { self[SessionDependencyKey.self] }
        set { self[SessionDependencyKey.self] = newValue }
    }
}
