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
    /// Retrieves a variable's value, starting at the current context and going upwards
    get {
      for dictionary in reverse(dictionaries) {
        if let value:AnyObject = dictionary[key] {
          return value
        }
      }

      return nil
    }

    /// Set a variable in the current context, deleting the variable if it's nil
    set(value) {
      if dictionaries.count > 0 {
        var dictionary = dictionaries.removeLast()
        dictionary[key] = value
        dictionaries.append(dictionary)
      }
    }
  }

  public func push() {
    push(Dictionary<String, AnyObject>())
  }

  public func push(dictionary:Dictionary<String, AnyObject>) {
    dictionaries.append(dictionary)
  }

  public func pop() {
    dictionaries.removeLast()
  }
}

public func ==(lhs:Context, rhs:Context) -> Bool {
  return lhs.dictionaries == rhs.dictionaries
}
