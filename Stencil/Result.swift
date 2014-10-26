import Foundation

public protocol Error : Printable {
    
}

public func ==(lhs:Error, rhs:Error) -> Bool {
    return lhs.description == rhs.description
}

public enum Result : Equatable {
    case Success(String)
    case Error(Stencil.Error)
}

public func ==(lhs:Result, rhs:Result) -> Bool {
    switch (lhs, rhs) {
    case (.Success(let lhsValue), .Success(let rhsValue)):
        return lhsValue == rhsValue
    case (.Error(let lhsValue), .Error(let rhsValue)):
        return lhsValue == rhsValue
    default:
        return false
    }
}
