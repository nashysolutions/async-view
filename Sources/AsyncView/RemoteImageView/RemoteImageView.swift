import SwiftUI
import Cache

public struct RemoteImageView<Placeholder: View>: View {
    
    let url: URL
    let cacheExpiry: Expiry
    let placeholder: (_ isFetching: Bool) -> Placeholder
    let contentMode: ContentMode
    
    public init(
        url: URL,
        cacheExpiry: Expiry,
        placeholder: @escaping (_ isFetching: Bool) -> Placeholder,
        contentMode: ContentMode = .fit
    ) {
        self.url = url
        self.cacheExpiry = cacheExpiry
        self.placeholder = placeholder
        self.contentMode = contentMode
    }
    
    public var body: some View {
        AsyncImageView(
            url: url,
            expiry: cacheExpiry,
            placeholder: placeholder,
            content: {
                imageView(for: $0)
            }
        )
    }
    
    @ViewBuilder
    private func imageView(for data: Data) -> some View {
        // Data validation has been performed.
        let image = PortableImage(data: data)!
        #if os(macOS)
        Image(nsImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
        #elseif os(iOS)
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: contentMode)
        #endif
    }
}
