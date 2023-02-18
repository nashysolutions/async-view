import SwiftUI
import Cache
import Dependencies

struct AsyncImageView<PlaceholderView: View, Content: View>: View {
        
    @StateObject private var model: AsyncImageModel
    
    let placeholder: (_ isFetching: Bool) -> PlaceholderView
    let content: (_ chapperone: Data) -> Content
    let onChange: (AsyncResult<Data>) -> Void
    
    init(
        url: URL,
        expiry: Expiry,
        placeholder: @escaping (Bool) -> PlaceholderView,
        onChange: @escaping (AsyncResult<Data>) -> Void = { _ in },
        content: @escaping (Data) -> Content
    ) {
        self._model = StateObject(wrappedValue: AsyncImageModel(url: url, expiry: expiry))
        self.placeholder = placeholder
        self.onChange = onChange
        self.content = content
    }
    
    var body: some View {
        AsyncView(model: model) {
            placeholder(true)
        } errorView: { _ in
            placeholder(false)
        } contentView: { image in
            content(image)
        }
        .onAppear {
            Task {
                await model.load()
            }
        }
        .onReceive(model.$result) { change in
            let result = change as AsyncResult<Data>
            onChange(result)
        }
    }
}
