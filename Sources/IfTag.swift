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


enum Operator {
  case infix(String, Int, InfixOperator.Type)
  case prefix(String, Int, PrefixOperator.Type)

  var name: String {
    switch self {
    case .infix(let name, _, _):
      return name
    case .prefix(let name, _, _):
      return name
    }
  }
}


let operators: [Operator] = [
  .infix("or", 6, OrExpression.self),
  .infix("and", 7, AndExpression.self),
  .prefix("not", 8, NotExpression.self),
]


func findOperator(name: String) -> Operator? {
  for op in operators {
    if op.name == name {
      return op
    }
  }

  return nil
}


enum IfToken {
  case infix(name: String, bindingPower: Int, op: InfixOperator.Type)
  case prefix(name: String, bindingPower: Int, op: PrefixOperator.Type)
  case variable(Variable)
  case end

  var bindingPower: Int {
    switch self {
    case .infix(_, let bindingPower, _):
      return bindingPower
    case .prefix(_, let bindingPower, _):
      return bindingPower
    case .variable(_):
      return 0
    case .end:
        return 0
    }
  }

  func nullDenotation(parser: IfExpressionParser) throws -> Expression {
    switch self {
    case .infix(let name, _, _):
      throw TemplateSyntaxError("'if' expression error: infix operator '\(name)' doesn't have a left hand side")
    case .prefix(_, let bindingPower, let op):
      let expression = try parser.expression(bindingPower: bindingPower)
      return op.init(expression: expression)
    case .variable(let variable):
      return VariableExpression(variable: variable)
    case .end:
      throw TemplateSyntaxError("'if' expression error: end")
    }
  }

  func leftDenotation(left: Expression, parser: IfExpressionParser) throws -> Expression {
    switch self {
    case .infix(_, let bindingPower, let op):
      let right = try parser.expression(bindingPower: bindingPower)
      return op.init(lhs: left, rhs: right)
    case .prefix(let name, _, _):
      throw TemplateSyntaxError("'if' expression error: prefix operator '\(name)' was called with a left hand side")
    case .variable(let variable):
      throw TemplateSyntaxError("'if' expression error: variable '\(variable)' was called with a left hand side")
    case .end:
      throw TemplateSyntaxError("'if' expression error: end")
    }
  }

  var isEnd: Bool {
    switch self {
    case .end:
      return true
    default:
      return false
    }
  }
}


final class IfExpressionParser {
  let tokens: [IfToken]
  var position: Int = 0

  init(components: [String]) {
    self.tokens = components.map { component in
      if let op = findOperator(name: component) {
        switch op {
        case .infix(let name, let bindingPower, let cls):
          return .infix(name: name, bindingPower: bindingPower, op: cls)
        case .prefix(let name, let bindingPower, let cls):
          return .prefix(name: name, bindingPower: bindingPower, op: cls)
        }
      }

      return .variable(Variable(component))
    }
  }

  var currentToken: IfToken {
    if tokens.count > position {
      return tokens[position]
    }

    return .end
  }

  var nextToken: IfToken {
    position += 1
    return currentToken
  }

  func parse() throws -> Expression {
    let expression = try self.expression()

    if !currentToken.isEnd {
      throw TemplateSyntaxError("'if' expression error: dangling token")
    }

    return expression
  }

  func expression(bindingPower: Int = 0) throws -> Expression {
    var token = currentToken
    position += 1

    var left = try token.nullDenotation(parser: self)

    while bindingPower < currentToken.bindingPower {
      token = currentToken
      position += 1
      left = try token.leftDenotation(left: left, parser: self)
    }

    return left
  }
}


func parseExpression(components: [String]) throws -> Expression {
  let parser = IfExpressionParser(components: components)
  return try parser.parse()
}


class IfNode : NodeType {
  let expression: Expression
  let trueNodes: [NodeType]
  let falseNodes: [NodeType]

  class func parse(_ parser: TokenParser, token: Token) throws -> NodeType {
    var components = token.components()
    guard components.count == 2 else {
      throw TemplateSyntaxError("'if' statements should use the following 'if condition' `\(token.contents)`.")
    }
    components.removeFirst()
    var trueNodes = [NodeType]()
    var falseNodes = [NodeType]()

    trueNodes = try parser.parse(until(["endif", "else"]))

    guard let token = parser.nextToken() else {
      throw TemplateSyntaxError("`endif` was not found.")
    }

    if token.contents == "else" {
      falseNodes = try parser.parse(until(["endif"]))
      _ = parser.nextToken()
    }

    let expression = try parseExpression(components: components)
    return IfNode(expression: expression, trueNodes: trueNodes, falseNodes: falseNodes)
  }

  class func parse_ifnot(_ parser: TokenParser, token: Token) throws -> NodeType {
    var components = token.components()
    guard components.count == 2 else {
      throw TemplateSyntaxError("'ifnot' statements should use the following 'ifnot condition' `\(token.contents)`.")
    }
    components.removeFirst()
    var trueNodes = [NodeType]()
    var falseNodes = [NodeType]()

    falseNodes = try parser.parse(until(["endif", "else"]))

    guard let token = parser.nextToken() else {
      throw TemplateSyntaxError("`endif` was not found.")
    }

    if token.contents == "else" {
      trueNodes = try parser.parse(until(["endif"]))
      _ = parser.nextToken()
    }

    let expression = try parseExpression(components: components)
    return IfNode(expression: expression, trueNodes: trueNodes, falseNodes: falseNodes)
  }

  init(expression: Expression, trueNodes: [NodeType], falseNodes: [NodeType]) {
    self.expression = expression
    self.trueNodes = trueNodes
    self.falseNodes = falseNodes
  }

  func render(_ context: Context) throws -> String {
    let truthy = try expression.evaluate(context: context)

    return try context.push {
      if truthy {
        return try renderNodes(trueNodes, context)
      } else {
        return try renderNodes(falseNodes, context)
      }
    }
  }
}
