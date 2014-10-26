import Foundation

public struct Variable : Equatable {
    public let variable:String

    public init(_ variable:String) {
        self.variable = variable
    }

    private func lookup() -> [String] {
        return variable.componentsSeparatedByString(".")
    }

    public func resolve(context:Context) -> AnyObject? {
        var current:AnyObject? = context

        if (variable.hasPrefix("'") && variable.hasSuffix("'")) || (variable.hasPrefix("\"") && variable.hasSuffix("\"")) {
            return variable.substringWithRange(variable.startIndex.successor() ..< variable.endIndex.predecessor())
        }

        for bit in lookup() {
            if let context = current as? Context {
                current = context[bit]
            } else if let dictionary = current as? Dictionary<String, AnyObject> {
                current = dictionary[bit]
            } else if let array = current as? [AnyObject] {
                if let index = bit.toInt() {
                    current = array[index]
                } else if bit == "first" {
                    current = array.first
                } else if bit == "last" {
                    current = array.last
                } else if bit == "count" {
                    current = countElements(array)
                }
            } else if let object = current as? NSObject {
                current = object.valueForKey(bit)
            } else {
                return nil
            }
        }

        return current
    }
}

public func ==(lhs:Variable, rhs:Variable) -> Bool {
    return lhs.variable == rhs.variable
}
