import Foundation

public enum Token : Equatable {
    case Text(value:String)
    case Variable(value:String)
    case Comment(value:String)
    case Block(value:String)

    /// Returns the underlying value as an array seperated by spaces
    func components() -> [String] {
        // TODO: Make this smarter and treat quoted strings as a single component
        let characterSet = NSCharacterSet.whitespaceAndNewlineCharacterSet()
        
        func strip(value: String) -> [String] {
            return value.stringByTrimmingCharactersInSet(characterSet).componentsSeparatedByCharactersInSet(characterSet)
        }

        switch self {
            case .Block(let value):
                return strip(value)
            case .Variable(let value):
                return strip(value)
            case .Text(let value):
                return strip(value)
            case .Comment(let value):
                return strip(value)
        }
    }

    var contents:String {
        switch self {
            case .Block(let value):
                return value
            case .Variable(let value):
                return value
            case .Text(let value):
                return value
            case .Comment(let value):
                return value
        }
    }
}

public func ==(lhs:Token, rhs:Token) -> Bool {
    switch (lhs, rhs) {
        case (.Text(let lhsValue), .Text(let rhsValue)):
            return lhsValue == rhsValue
        case (.Variable(let lhsValue), .Variable(let rhsValue)):
            return lhsValue == rhsValue
        case (.Block(let lhsValue), .Block(let rhsValue)):
            return lhsValue == rhsValue
        case (.Comment(let lhsValue), .Comment(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
    }
}
