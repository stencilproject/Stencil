protocol Expression: CustomStringConvertible {
  func evaluate(context: Context) throws -> Bool
}


protocol InfixOperator: Expression {
  init(lhs: Expression, rhs: Expression)
}


protocol PrefixOperator: Expression {
  init(expression: Expression)
}


final class StaticExpression: Expression, CustomStringConvertible {
  let value: Bool

  init(value: Bool) {
    self.value = value
  }

  func evaluate(context: Context) throws -> Bool {
    return value
  }

  var description: String {
    return "\(value)"
  }
}


final class VariableExpression: Expression, CustomStringConvertible {
  let variable: Variable

  init(variable: Variable) {
    self.variable = variable
  }

  var description: String {
    return "(variable: \(variable.variable))"
  }

  /// Resolves a variable in the given context as boolean
  func resolve(context: Context, variable: Variable) throws -> Bool {
    let result = try variable.resolve(context)
    var truthy = false

    if let result = result as? [Any] {
      truthy = !result.isEmpty
    } else if let result = result as? [String:Any] {
      truthy = !result.isEmpty
    } else if let result = result as? Bool {
      truthy = result
    } else if let result = result as? Int {
      truthy = result > 0
    } else if let result = result as? Float {
      truthy = result > 0
    } else if let result = result as? Double {
      truthy = result > 0
    } else if result != nil {
      truthy = true
    }

    return truthy
  }

  func evaluate(context: Context) throws -> Bool {
    return try resolve(context: context, variable: variable)
  }
}


final class NotExpression: Expression, PrefixOperator, CustomStringConvertible {
  let expression: Expression

  init(expression: Expression) {
    self.expression = expression
  }

  var description: String {
    return "not \(expression)"
  }

  func evaluate(context: Context) throws -> Bool {
    return try !expression.evaluate(context: context)
  }
}


final class OrExpression: Expression, InfixOperator, CustomStringConvertible {
  let lhs: Expression
  let rhs: Expression

  init(lhs: Expression, rhs: Expression) {
    self.lhs = lhs
    self.rhs = rhs
  }

  var description: String {
    return "(\(lhs) or \(rhs))"
  }

  func evaluate(context: Context) throws -> Bool {
    let lhs = try self.lhs.evaluate(context: context)
    if lhs {
      return lhs
    }

    return try rhs.evaluate(context: context)
  }
}


final class AndExpression: Expression, InfixOperator, CustomStringConvertible {
  let lhs: Expression
  let rhs: Expression

  init(lhs: Expression, rhs: Expression) {
    self.lhs = lhs
    self.rhs = rhs
  }

  var description: String {
    return "(\(lhs) and \(rhs))"
  }

  func evaluate(context: Context) throws -> Bool {
    let lhs = try self.lhs.evaluate(context: context)
    if !lhs {
      return lhs
    }

    return try rhs.evaluate(context: context)
  }
}
