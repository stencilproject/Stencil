func capitalise(_ value: Any?) -> Any? {
  return stringify(value).capitalized
}

func uppercase(_ value: Any?) -> Any? {
  return stringify(value).uppercased()
}

func lowercase(_ value: Any?) -> Any? {
  return stringify(value).lowercased()
}

func titlecase(_ value: Any?) -> Any? {
  return stringify(value).titlecased
}

extension String {
  var titlecased: String {
    guard !isEmpty else { return "" }
    return components(separatedBy: " ")
      .map({
        let first = String($0.characters.prefix(1)).capitalized
        let other = String($0.characters.dropFirst())
        return first + other
      })
    .joined(separator: " ")
  }
}

func defaultFilter(value: Any?, arguments: [Any?]) -> Any? {
  // value can be optional wrapping nil, so this way we check for underlying value
  if let value = value, String(describing: value) != "nil" {
    return value
  }

  for argument in arguments {
    if let argument = argument {
      return argument
    }
  }

  return nil
}

func joinFilter(value: Any?, arguments: [Any?]) throws -> Any? {
  guard arguments.count < 2 else {
    throw TemplateSyntaxError("'join' filter takes a single argument")
  }

  let separator = stringify(arguments.first ?? "")

  if let value = value as? [Any] {
    return value
      .map(stringify)
      .joined(separator: separator)
  }

  return value
}
