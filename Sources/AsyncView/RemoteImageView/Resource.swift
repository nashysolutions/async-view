#if canImport(UIKit)
import UIKit
typealias PortableImage = UIImage
#elseif canImport(AppKit)
import AppKit
typealias PortableImage = NSImage
#endif

struct Resource: Identifiable {
    
    let id: URL
    let data: Data
    
    var image: PortableImage? {
        PortableImage(data: data)
    }
}
