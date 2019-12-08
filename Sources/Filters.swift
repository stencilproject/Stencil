func capitalise(_ value: Any?) -> Any? {
  if let array = value as? [Any?] {
    return array.map { stringify($0).capitalized }
  } else {
    return stringify(value).capitalized
  }
}

func uppercase(_ value: Any?) -> Any? {
  if let array = value as? [Any?] {
    return array.map { stringify($0).uppercased() }
  } else {
    return stringify(value).uppercased()
  }
}

func lowercase(_ value: Any?) -> Any? {
  if let array = value as? [Any?] {
    return array.map { stringify($0).lowercased() }
  } else {
    return stringify(value).lowercased()
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
    throw TemplateSyntaxError("'join' filter takes at most one argument")
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
    throw TemplateSyntaxError("'split' filter takes at most one argument")
  }

  let separator = stringify(arguments.first ?? " ")
  if let value = value as? String {
    return value.components(separatedBy: separator)
  }

  return value
}

func indentFilter(value: Any?, arguments: [Any?]) throws -> Any? {
  guard arguments.count <= 3 else {
    throw TemplateSyntaxError("'indent' filter can take at most 3 arguments")
  }

  var indentWidth = 4
  if !arguments.isEmpty {
    guard let value = arguments[0] as? Int else {
      throw TemplateSyntaxError("""
        'indent' filter width argument must be an Integer (\(String(describing: arguments[0])))
        """)
    }
    indentWidth = value
  }

  var indentationChar = " "
  if arguments.count > 1 {
    guard let value = arguments[1] as? String else {
      throw TemplateSyntaxError("""
        'indent' filter indentation argument must be a String (\(String(describing: arguments[1]))
        """)
    }
    indentationChar = value
  }

  var indentFirst = false
  if arguments.count > 2 {
    guard let value = arguments[2] as? Bool else {
      throw TemplateSyntaxError("'indent' filter indentFirst argument must be a Bool")
    }
    indentFirst = value
  }

  let indentation = [String](repeating: indentationChar, count: indentWidth).joined()
  return indent(stringify(value), indentation: indentation, indentFirst: indentFirst)
}

func indent(_ content: String, indentation: String, indentFirst: Bool) -> String {
  guard !indentation.isEmpty else { return content }

  var lines = content.components(separatedBy: .newlines)
  let firstLine = (indentFirst ? indentation : "") + lines.removeFirst()
  let result = lines.reduce([firstLine]) { result, line in
    result + [(line.isEmpty ? "" : "\(indentation)\(line)")]
  }
  return result.joined(separator: "\n")
}

func filterFilter(value: Any?, arguments: [Any?], context: Context) throws -> Any? {
  guard let value = value else { return nil }
  guard arguments.count == 1 else {
    throw TemplateSyntaxError("'filter' filter takes one argument")
  }

  let attribute = stringify(arguments[0])

  let expr = try context.environment.compileFilter("$0|\(attribute)")
  return try context.push(dictionary: ["$0": value]) {
    try expr.resolve(context)
  }
}

func mapFilter(value: Any?, arguments: [Any?], context: Context) throws -> Any? {
  guard arguments.count >= 1 && arguments.count <= 2 else {
    throw TemplateSyntaxError("'map' filter takes one or two arguments")
  }

  let attribute = stringify(arguments[0])
  let variable = Variable("map_item.\(attribute)")
  let defaultValue = arguments.count == 2 ? arguments[1] : nil

  let resolveVariable = { (item: Any) throws -> Any in
    let result = try context.push(dictionary: ["map_item": item]) {
      try variable.resolve(context)
    }
    if let result = result { return result }
    else if let defaultValue = defaultValue { return defaultValue }
    else { return result as Any }
  }


  if let array = value as? [Any] {
    return try array.map(resolveVariable)
  } else {
    return try resolveVariable(value as Any)
  }
}

func compactFilter(value: Any?, arguments: [Any?], context: Context) throws -> Any? {
  guard arguments.count <= 1 else {
    throw TemplateSyntaxError("'compact' filter takes at most one argument")
  }

  guard var array = value as? [Any?] else { return value }

  if arguments.count == 1 {
    guard let mapped = try mapFilter(value: array, arguments: arguments, context: context) as? [Any?] else {
      return value
    }
    array = mapped
  }

  return array.compactMap { item -> Any? in
    guard let unwrapped = item, String(describing: unwrapped) != "nil" else { return nil }
    return unwrapped
  }
}

func filterEachFilter(value: Any?, arguments: [Any?], context: Context) throws -> Any? {
  guard arguments.count == 1 else {
    throw TemplateSyntaxError("'filterEach' filter takes one argument")
  }

  guard let token = Lexer(templateString: stringify(arguments[0])).tokenize().first else {
    throw TemplateSyntaxError("Can't parse filter expression")
  }

  let expr = try context.environment.compileExpression(components: token.components, containedIn: token)

  if let array = value as? [Any] {
    return try array.filter {
      try context.push(dictionary: ["$0": $0]) {
        try expr.evaluate(context: context)
      }
    }
  }

  return value
}
