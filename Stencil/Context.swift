import Foundation

/// A container for template variables.
public class Context : Equatable {
    var dictionaries:[Dictionary<String, AnyObject>]

    public init(dictionary:Dictionary<String, AnyObject>) {
        dictionaries = [dictionary]
    }

    public init() {
        dictionaries = []
    }

    public subscript(key: String) -> AnyObject? {
        get {
            for dictionary in reverse(dictionaries) {
                if let value:AnyObject = dictionary[key] {
                    return value
                }
            }

            return nil
        }

        set(value) {
            if dictionaries.count > 0 {
                var dictionary = dictionaries.removeLast()
                dictionary[key] = value
                dictionaries.append(dictionary)
            }
        }
    }

    public func push() {
        push(Dictionary<String, String>())
    }

    public func push(dictionary:Dictionary<String, String>) {
        dictionaries.append(dictionary)
    }

    public func pop() {
        dictionaries.removeLast()
    }
}

public func ==(lhs:Context, rhs:Context) -> Bool {
    return lhs.dictionaries == rhs.dictionaries
}
