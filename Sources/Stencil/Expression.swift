//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

public protocol Expression: CustomStringConvertible, Resolvable {
  func evaluate(context: Context) throws -> Bool
}

extension Expression {
  func resolve(_ context: Context) throws -> Any? {
    try "\(evaluate(context: context))"
  }
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
    value
  }

  var description: String {
    "\(value)"
  }
}

final class VariableExpression: Expression, CustomStringConvertible {
  let variable: Resolvable

  init(variable: Resolvable) {
    self.variable = variable
  }

  var description: String {
    "(variable: \(variable))"
  }

  func resolve(_ context: Context) throws -> Any? {
    try variable.resolve(context)
  }

  /// Resolves a variable in the given context as boolean
  func evaluate(context: Context) throws -> Bool {
    let result = try variable.resolve(context)
    var truthy = false

    if let result = result as? [Any] {
      truthy = !result.isEmpty
    } else if let result = result as? [String: Any] {
      truthy = !result.isEmpty
    } else if let result = result as? Bool {
      truthy = result
    } else if let result = result as? String {
      truthy = !result.isEmpty
    } else if let value = result, let result = toNumber(value: value) {
      truthy = result > 0
    } else if result != nil {
      truthy = true
    }

    return truthy
  }
}

final class NotExpression: Expression, PrefixOperator, CustomStringConvertible {
  let expression: Expression

  init(expression: Expression) {
    self.expression = expression
  }

  var description: String {
    "not \(expression)"
  }

  func evaluate(context: Context) throws -> Bool {
    try !expression.evaluate(context: context)
  }
}

final class InExpression: Expression, InfixOperator, CustomStringConvertible {
  let lhs: Expression
  let rhs: Expression

  init(lhs: Expression, rhs: Expression) {
    self.lhs = lhs
    self.rhs = rhs
  }

  var description: String {
    "(\(lhs) in \(rhs))"
  }

  func evaluate(context: Context) throws -> Bool {
    if let lhs = lhs as? VariableExpression, let rhs = rhs as? VariableExpression {
      let lhsValue = try lhs.variable.resolve(context)
      let rhsValue = try rhs.variable.resolve(context)

      if let lhs = lhsValue as? AnyHashable, let rhs = rhsValue as? [AnyHashable] {
        return rhs.contains(lhs)
      } else if let lhs = lhsValue as? Int, let rhs = rhsValue as? CountableClosedRange<Int> {
        return rhs.contains(lhs)
      } else if let lhs = lhsValue as? Int, let rhs = rhsValue as? CountableRange<Int> {
        return rhs.contains(lhs)
      } else if let lhs = lhsValue as? String, let rhs = rhsValue as? String {
        return rhs.contains(lhs)
      } else if lhsValue == nil && rhsValue == nil {
        return true
      }
    }

    return false
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
    "(\(lhs) or \(rhs))"
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
    "(\(lhs) and \(rhs))"
  }

  func evaluate(context: Context) throws -> Bool {
    let lhs = try self.lhs.evaluate(context: context)
    if !lhs {
      return lhs
    }

    return try rhs.evaluate(context: context)
  }
}

class EqualityExpression: Expression, InfixOperator, CustomStringConvertible {
  let lhs: Expression
  let rhs: Expression

  required init(lhs: Expression, rhs: Expression) {
    self.lhs = lhs
    self.rhs = rhs
  }

  var description: String {
    "(\(lhs) == \(rhs))"
  }

  func evaluate(context: Context) throws -> Bool {
    if let lhs = lhs as? VariableExpression, let rhs = rhs as? VariableExpression {
      let lhsValue = try lhs.variable.resolve(context)
      let rhsValue = try rhs.variable.resolve(context)

      if let lhs = lhsValue, let rhs = rhsValue {
        if let lhs = toNumber(value: lhs), let rhs = toNumber(value: rhs) {
          return lhs == rhs
        } else if let lhs = lhsValue as? String, let rhs = rhsValue as? String {
          return lhs == rhs
        } else if let lhs = lhsValue as? Bool, let rhs = rhsValue as? Bool {
          return lhs == rhs
        }
      } else if lhsValue == nil && rhsValue == nil {
        return true
      }
    }

    return false
  }
}

class NumericExpression: Expression, InfixOperator, CustomStringConvertible {
  let lhs: Expression
  let rhs: Expression

  required init(lhs: Expression, rhs: Expression) {
    self.lhs = lhs
    self.rhs = rhs
  }

  var description: String {
    "(\(lhs) \(symbol) \(rhs))"
  }

  func evaluate(context: Context) throws -> Bool {
    if let lhs = lhs as? VariableExpression, let rhs = rhs as? VariableExpression {
      let lhsValue = try lhs.variable.resolve(context)
      let rhsValue = try rhs.variable.resolve(context)

      if let lhs = lhsValue, let rhs = rhsValue {
        if let lhs = toNumber(value: lhs), let rhs = toNumber(value: rhs) {
          return compare(lhs: lhs, rhs: rhs)
        }
      }
    }

    return false
  }

  var symbol: String {
    ""
  }

  func compare(lhs: Number, rhs: Number) -> Bool {
    false
  }
}

class MoreThanExpression: NumericExpression {
  override var symbol: String {
    ">"
  }

  override func compare(lhs: Number, rhs: Number) -> Bool {
    lhs > rhs
  }
}

class MoreThanEqualExpression: NumericExpression {
  override var symbol: String {
    ">="
  }

  override func compare(lhs: Number, rhs: Number) -> Bool {
    lhs >= rhs
  }
}

class LessThanExpression: NumericExpression {
  override var symbol: String {
    "<"
  }

  override func compare(lhs: Number, rhs: Number) -> Bool {
    lhs < rhs
  }
}

class LessThanEqualExpression: NumericExpression {
  override var symbol: String {
    "<="
  }

  override func compare(lhs: Number, rhs: Number) -> Bool {
    lhs <= rhs
  }
}

class InequalityExpression: EqualityExpression {
  override var description: String {
    "(\(lhs) != \(rhs))"
  }

  override func evaluate(context: Context) throws -> Bool {
    try !super.evaluate(context: context)
  }
}

// swiftlint:disable:next cyclomatic_complexity
func toNumber(value: Any) -> Number? {
  if let value = value as? Float {
    return Number(value)
  } else if let value = value as? Double {
    return Number(value)
  } else if let value = value as? UInt {
    return Number(value)
  } else if let value = value as? Int {
    return Number(value)
  } else if let value = value as? Int8 {
    return Number(value)
  } else if let value = value as? Int16 {
    return Number(value)
  } else if let value = value as? Int32 {
    return Number(value)
  } else if let value = value as? Int64 {
    return Number(value)
  } else if let value = value as? UInt8 {
    return Number(value)
  } else if let value = value as? UInt16 {
    return Number(value)
  } else if let value = value as? UInt32 {
    return Number(value)
  } else if let value = value as? UInt64 {
    return Number(value)
  } else if let value = value as? Number {
    return value
  } else if let value = value as? Float64 {
    return Number(value)
  } else if let value = value as? Float32 {
    return Number(value)
  }

  return nil
}
