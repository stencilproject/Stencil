import Foundation

public protocol StencilError : Printable {
    
}

public func ==(lhs:StencilError, rhs:StencilError) -> Bool {
    return lhs.description == rhs.description
}

public enum StencilResult : Equatable {
    case Success(String)
    case Error(StencilError)
}

public func ==(lhs:StencilResult, rhs:StencilResult) -> Bool {
    switch (lhs, rhs) {
    case (.Success(let lhsValue), .Success(let rhsValue)):
        return lhsValue == rhsValue
    case (.Error(let lhsValue), .Error(let rhsValue)):
        return lhsValue == rhsValue
    default:
        return false
    }
}
