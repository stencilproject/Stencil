protocol Expression: CustomStringConvertible {
  func evaluate(context: Context) throws -> Any
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

  func evaluate(context: Context) throws -> Any {
    return value
  }

  var description: String {
    return "\(value)"
  }
}

class VariableExpression: Expression, CustomStringConvertible {
  let variable: Resolvable

  init(variable: Resolvable) {
    self.variable = variable
  }

  var description: String {
    return "(variable: \(variable))"
  }

  /// Resolves a variable in the given context as boolean
  func evaluate(context: Context) throws -> Any {
    let result = try variable.resolve(context)
    var truthy = false

    if let result = result as? [Any] {
      truthy = !result.isEmpty
    } else if let result = result as? [String:Any] {
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
    return "not \(expression)"
  }

  func evaluate(context: Context) throws -> Any {
    return try !(expression.evaluate(context: context) as! Bool)
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
    return "(\(lhs) in \(rhs))"
  }
  
  func evaluate(context: Context) throws -> Any {
    if let lhs = lhs as? VariableExpression, let rhs = rhs as? VariableExpression {
      let lhsValue = try lhs.variable.resolve(context)
      let rhsValue = try rhs.variable.resolve(context)
      
      if let lhs = lhsValue as? AnyHashable, let rhs = rhsValue as? [AnyHashable] {
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
    return "(\(lhs) or \(rhs))"
  }

  func evaluate(context: Context) throws -> Any {
    let lhs = try self.lhs.evaluate(context: context) as! Bool
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

  func evaluate(context: Context) throws -> Any {
    let lhs = try self.lhs.evaluate(context: context) as! Bool
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
    return "(\(lhs) == \(rhs))"
  }

  func evaluate(context: Context) throws -> Any {
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
    return "(\(lhs) \(op) \(rhs))"
  }

  func evaluate(context: Context) throws -> Any {
    if let lhs = lhs as? VariableExpression, let rhs = rhs as? VariableExpression {
      let lhsValue = try lhs.variable.resolve(context)
      let rhsValue = try rhs.variable.resolve(context)

      guard let lhs = lhsValue else {
        throw TemplateSyntaxError("left value is nil")
      }
      guard let lhsNumber = toNumber(value: lhs) else {
        throw TemplateSyntaxError("left value is not a number")
      }

      guard let rhs = rhsValue else {
        throw TemplateSyntaxError("right value is nil")
      }
      guard let rhsNumber = toNumber(value: rhs) else {
        throw TemplateSyntaxError("right value is not a number")
      }

      return compare(lhs: lhsNumber, rhs: rhsNumber)
    }

    return false
  }

  var op: String {
    return ""
  }

  func compare(lhs: Number, rhs: Number) -> Bool {
    return false
  }
}


final class MoreThanExpression: NumericExpression {
  override var op: String {
    return ">"
  }

  override func compare(lhs: Number, rhs: Number) -> Bool {
    return lhs > rhs
  }
}


final class MoreThanEqualExpression: NumericExpression {
  override var op: String {
    return ">="
  }

  override func compare(lhs: Number, rhs: Number) -> Bool {
    return lhs >= rhs
  }
}


final class LessThanExpression: NumericExpression {
  override var op: String {
    return "<"
  }

  override func compare(lhs: Number, rhs: Number) -> Bool {
    return lhs < rhs
  }
}


final class LessThanEqualExpression: NumericExpression {
  override var op: String {
    return "<="
  }

  override func compare(lhs: Number, rhs: Number) -> Bool {
    return lhs <= rhs
  }
}


final class InequalityExpression: EqualityExpression {
  override var description: String {
    return "(\(lhs) != \(rhs))"
  }

  override func evaluate(context: Context) throws -> Any {
    return try !(super.evaluate(context: context) as! Bool)
  }
}


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

class ArithmeticExpression: Expression, InfixOperator, CustomStringConvertible {
  let lhs: Expression
  let rhs: Expression

  required init(lhs: Expression, rhs: Expression) {
    self.lhs = lhs
    self.rhs = rhs
  }

  var description: String {
    return "(\(lhs) \(op) \(rhs))"
  }

  func evaluate(context: Context) throws -> Any {
    let lhsResult: Number
    if let lhs = lhs as? ArithmeticExpression {
      lhsResult = try lhs.evaluate(context: context) as! Number
    } else if let lhs = lhs as? VariableExpression {
      let lhsValue = try lhs.variable.resolve(context)

      guard let lhs = lhsValue else {
        throw TemplateSyntaxError("left value is nil")
      }
      guard let lhsNumber = toNumber(value: lhs) else {
        throw TemplateSyntaxError("left value '\(lhs)' is not a number")
      }
      lhsResult = lhsNumber
    } else {
      throw TemplateSyntaxError("invalid arithmetic expression")
    }

    let rhsResult: Number
    if let rhs = rhs as? ArithmeticExpression {
      rhsResult = try rhs.evaluate(context: context) as! Number
    } else if let rhs = rhs as? VariableExpression {
      let rhsValue = try rhs.variable.resolve(context)

      guard let rhs = rhsValue else {
        throw TemplateSyntaxError("right value is nil")
      }
      guard let rhsNumber = toNumber(value: rhs) else {
        throw TemplateSyntaxError("right value '\(rhs)' is not a number")
      }
      rhsResult = rhsNumber
    } else {
      throw TemplateSyntaxError("invalid arithmetic expression")
    }

    return calculate(lhs: lhsResult, rhs: rhsResult)
  }

  var op: String {
    return ""
  }

  func calculate(lhs: Number, rhs: Number) -> Number {
    return 0
  }
}

final class SumExpression: ArithmeticExpression {
  override var op: String {
    return "+"
  }

  override func calculate(lhs: Number, rhs: Number) -> Number {
    return lhs + rhs
  }
}

final class SubstractExpression: ArithmeticExpression {
  override var op: String {
    return "-"
  }

  override func calculate(lhs: Number, rhs: Number) -> Number {
    return lhs - rhs
  }
}

final class MultiplyExpression: ArithmeticExpression {
  override var op: String {
    return "*"
  }

  override func calculate(lhs: Number, rhs: Number) -> Number {
    return lhs * rhs
  }
}

final class DevideExpression: ArithmeticExpression {
  override var op: String {
    return "/"
  }

  override func calculate(lhs: Number, rhs: Number) -> Number {
    return lhs / rhs
  }
}


