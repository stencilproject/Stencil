func capitalise(_ value: Any?) -> Any? {
  return stringify(value).capitalized
}

func uppercase(_ value: Any?) -> Any? {
  return stringify(value).uppercased()
}

func lowercase(_ value: Any?) -> Any? {
  return stringify(value).lowercased()
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

func splitFilter(value: Any?, arguments: [Any?]) throws -> Any? {
  guard arguments.count < 2 else {
    throw TemplateSyntaxError("'split' filter takes a single argument")
  }

  let separator = stringify(arguments.first ?? " ")
  if let value = value as? String {
    return value.components(separatedBy: separator)
  }

  return value
}

func valueForKeyFilter(value: Any?, arguments: [Any?], context: Context) throws -> Any? {
  guard arguments.count == 1 else {
    throw TemplateSyntaxError("'split' filter takes a single argument")
  }

  let key = stringify(arguments[0])
  return try context.push(dictionary: ["filter_value": value as Any]) {
    return try Variable("filter_value.\(key)").resolve(context)
  }
}
