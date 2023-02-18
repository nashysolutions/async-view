import SwiftUI

public struct AsyncView<Model: AsyncModel, PlaceholderView: View, ContentView: View, ErrorView: View>: View {
    
    @StateObject private var model: Model
    
    let placeholderView: () -> PlaceholderView
    let contentView: (_ item: Model.Output) -> ContentView
    let errorView: (_ error: Error) -> ErrorView
    
    public init(
        model: Model,
        placeholderView: @escaping () -> PlaceholderView,
        errorView: @escaping (_ error: Error) -> ErrorView,
        contentView: @escaping (_ item: Model.Output
        ) -> ContentView) {
        self.placeholderView = placeholderView
        self.contentView = contentView
        self.errorView = errorView
        self._model = StateObject(wrappedValue: model)
    }
    
    public var body: some View {
        resultView
    }
    
    @ViewBuilder
    private var resultView: some View {
        switch model.result {
        case .empty:
            Color.clear
        case .inProgress:
            placeholderView()
        case let .success(value):
            contentView(value)
        case let .failure(error):
            errorView(error)
        }
    }
}
