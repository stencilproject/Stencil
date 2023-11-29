//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

/// A container for template variables.
public class Context {
  var dictionaries: [[String: Any?]]

  /// The context's environment, such as registered extensions, classes, …
  public var environment: Environment

  init(dictionaries: [[String: Any?]], environment: Environment) {
    self.dictionaries = dictionaries
    self.environment = environment
  }

  /// Create a context from a dictionary (and an env.)
  ///
  /// - Parameters:
  ///   - dictionary: The context's data
  ///   - environment: Environment such as extensions, …
  public convenience init(dictionary: [String: Any] = [:], environment: Environment? = nil) {
    self.init(
      dictionaries: dictionary.isEmpty ? [] : [dictionary],
      environment: environment ?? Environment()
    )
  }

  /// Access variables in this context by name
  public subscript(key: String) -> Any? {
    /// Retrieves a variable's value, starting at the current context and going upwards
    get {
      for dictionary in Array(dictionaries.reversed()) {
        if let value = dictionary[key] {
          return value
        }
      }

      return nil
    }

    /// Set a variable in the current context, deleting the variable if it's nil
    set(value) {
      if var dictionary = dictionaries.popLast() {
        dictionary[key] = value
        dictionaries.append(dictionary)
      }
    }
  }

  /// Push a new level into the Context
  ///
  /// - Parameters:
  ///   - dictionary: The new level data
  fileprivate func push(_ dictionary: [String: Any] = [:]) {
    dictionaries.append(dictionary)
  }

  /// Pop the last level off of the Context
  ///
  /// - returns: The popped level
  fileprivate func pop() -> [String: Any?]? {
    dictionaries.popLast()
  }

  /// Push a new level onto the context for the duration of the execution of the given closure
  ///
  /// - Parameters:
  ///   - dictionary: The new level data
  ///   - closure: The closure to execute
  /// - returns: Return value of the closure
  public func push<Result>(dictionary: [String: Any] = [:], closure: (() throws -> Result)) rethrows -> Result {
    push(dictionary)
    defer { _ = pop() }
    return try closure()
  }

  /// Flatten all levels of context data into 1, merging duplicate variables
  /// 
  /// - returns: All collected variables
  public func flatten() -> [String: Any] {
    var accumulator: [String: Any] = [:]

    for dictionary in dictionaries {
      for (key, value) in dictionary {
        if let value = value {
          accumulator.updateValue(value, forKey: key)
        }
      }
    }

    return accumulator
  }

  /// Cache result of block by its name in the context top-level, so that it can be later rendered
  /// via `{{ block.name }}`
  ///
  /// - Parameters:
  ///   - name: The name of the stored block
  ///   - content: The block's rendered content
  public func cacheBlock(_ name: String, content: String) {
    if var block = dictionaries.first?["block"] as? [String: String] {
      block[name] = content
      dictionaries[0]["block"] = block
    } else {
      dictionaries.insert(["block": [name: content]], at: 0)
    }
  }
}
