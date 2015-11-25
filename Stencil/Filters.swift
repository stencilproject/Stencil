func toString(value: Any?) -> String? {
  if let value = value as? String {
    return value
  } else if let value = value as? CustomStringConvertible {
    return value.description
  }

  return nil
}

func capitalise(value: Any?, arguments: [Any?]) -> Any? {
  if let value = toString(value) {
    return value.capitalizedString
  }

  return value
}

func uppercase(value: Any?, arguments: [Any?]) -> Any? {
  if let value = toString(value) {
    return value.uppercaseString
  }

  return value
}

func lowercase(value: Any?, arguments: [Any?]) -> Any? {
  if let value = toString(value) {
    return value.lowercaseString
  }

  return value
}
