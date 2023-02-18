import Foundation

public enum AsyncResult<Output> {
    case empty
    case inProgress
    case success(Output)
    case failure(Error)
}
