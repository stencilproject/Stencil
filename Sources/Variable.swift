import Foundation


class FilterExpression : Resolvable {
  let filters: [Filter]
  let variable: Variable

  init(token: String, parser: TokenParser) throws {
    let bits = token.characters.split("|").map({ String($0).trim(" ") })
    if bits.isEmpty {
      filters = []
      variable = Variable("")
      throw TemplateSyntaxError("Variable tags must include at least 1 argument")
    }

    variable = Variable(bits[0])
    let filterBits = bits[1 ..< bits.endIndex]

    do {
      filters = try filterBits.map { try parser.findFilter($0) }
    } catch {
      filters = []
      throw error
    }
  }

  func resolve(context: Context) throws -> Any? {
    let result = try variable.resolve(context)

    return try filters.reduce(result) { x, y in
      return try y(x)
    }
  }
}

/// A structure used to represent a template variable, and to resolve it in a given context.
public struct Variable : Equatable, Resolvable {
  public let variable: String

  /// Create a variable with a string representing the variable
  public init(_ variable: String) {
    self.variable = variable
  }

  private func lookup() -> [String] {
    return variable.characters.split(".").map(String.init)
  }

  /// Resolve the variable in the given context
  public func resolve(context: Context) throws -> Any? {
    var current: Any? = context

    if (variable.hasPrefix("'") && variable.hasSuffix("'")) || (variable.hasPrefix("\"") && variable.hasSuffix("\"")) {
      // String literal
      return variable[variable.startIndex.successor() ..< variable.endIndex.predecessor()]
    }

    for bit in lookup() {
      if let context = current as? Context {
        current = context[bit]
      } else if let dictionary = resolveDictionary(current) {
        current = dictionary[bit]
      } else if let array = resolveArray(current) {
        if let index = Int(bit) {
          current = array[index]
        } else if bit == "first" {
          current = array.first
        } else if bit == "last" {
          current = array.last
        } else if bit == "count" {
          current = array.count
        }
      } else if let object = current as? NSObject {  // NSKeyValueCoding
#if os(Linux)
        return nil
#else
        current = object.valueForKey(bit)
#endif
      } else {
        return nil
      }
    }

    return normalize(current)
  }
}

public func ==(lhs: Variable, rhs: Variable) -> Bool {
  return lhs.variable == rhs.variable
}


func resolveDictionary(current: Any?) -> [String: Any]? {
  switch current {
  case let dictionary as [String: Any]:
      return dictionary
  case let dictionary as [String: AnyObject]:
      var result: [String: Any] = [:]
      for (k, v) in dictionary {
          result[k] = v as Any
      }
      return result
  case let dictionary as NSDictionary:
      var result: [String: Any] = [:]
      for (k, v) in dictionary {
          if let k = k as? String {
              result[k] = v as Any
          }
      }
      return result
  default:
      return nil
  }
}

func resolveArray(current: Any?) -> [Any]? {
  switch current {
  case let array as [Any]:
      return array
  case let array as [AnyObject]:
      return array.map { $0 as Any }
  case let array as NSArray:
      return array.map { $0 as Any }
  default:
      return nil
  }
}

func normalize(current: Any?) -> Any? {
  if let array = resolveArray(current) {
    return array
  }

  if let dictionary = resolveDictionary(current) {
    return dictionary
  }

  return current
}
