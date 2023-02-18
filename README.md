# AsyncView

[![](https://img.shields.io/badge/Platform%20Compatibility-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS-red?logo=swift)](https://developer.apple.com)

## Usage

To fetching an image and cache it (in memory only), whilst receiving `isFetching` feedback. The following uses `URLSession.shared` and any errors fail silently (isFetching becomes false).

```
private func makeImageView() -> some View {
    RemoteImageView(
        url: URL(string: "http://url/image.png")!,
        cacheExpiry: .short,
        placeholder: makePlaceholder,
        contentMode: .fit
    )
}

private func makePlaceholder(_ isFetching: Bool) -> some View {
    ZStack {
        Image("placeholder")
            .resizable()
            .aspectRatio(contentMode: .fit)
        Text("Fetching: \(String(describing: isFetching))")
    }
}
```

If you would like to fetch data, create a custom model.

```swift
struct CatView: View {
    
    @StateObject private var model = CatModel()
    
    var body: some View {
        AsyncView(model: model) {
            ProgressView()
        } errorView: { error in
            ErrorView(error: error)
        } contentView: { data in
            Image(uiImage: UIImage(data: data)!)
                .resizable()
                .aspectRatio(contentMode: .fit)
        }
        .onAppear {
            Task {
                await model.load()
            }
        }
    }
}

final class CatModel: AsyncModel, ObservableObject {
    
    @Published var result: AsyncResult<Data> = .empty
    
    var asyncOperationBlock: AsyncOperation {
        return { [unowned self] in
            try await Task.sleep(nanoseconds: NSEC_PER_SEC * 1) // simulate loading
            return try Data(contentsOf: file)
        }
    }
    
    private var file: URL {
        Bundle.main.url(forResource: "Cat", withExtension: "png")!
    }
}

struct ErrorView: View {
    
    var error: Error
    
    var body: some View {
        Text(error.localizedDescription)
    }
}
```
