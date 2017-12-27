import Foundation

class ForNode : NodeType {
  let resolvable: Resolvable
  let loopVariables: [String]
  let nodes:[NodeType]
  let emptyNodes: [NodeType]
  let `where`: Expression?

  class func parse(_ parser:TokenParser, token:Token) throws -> NodeType {
    var components = token.components()
    
    let error = TemplateSyntaxError("'for' statements should use the following 'for x in y where condition' `\(token.contents)`.")
    guard components.count >= 3 else { throw error }

    // this will allow using comma with spaces between loop variables
    if components[1].hasSuffix(",") {
      components[1] = "\(components[1])\(components.remove(at: 2))"
    }
    
    guard components[2] == "in" && (components.count == 4 || (components.count >= 6 && components[4] == "where")) else {
      throw error
    }

    let loopVariables = components[1].characters
      .split(separator: ",")
      .map(String.init)
      .map { $0.trimmingCharacters(in: CharacterSet.whitespaces) }

    let variable = components[3]

    var emptyNodes = [NodeType]()

    let forNodes = try parser.parse(until(["endfor", "empty"]))

    guard let token = parser.nextToken() else {
      throw TemplateSyntaxError("`endfor` was not found.")
    }

    if token.contents == "empty" {
      emptyNodes = try parser.parse(until(["endfor"]))
      _ = parser.nextToken()
    }

    let filter = try parser.compileFilter(variable)
    let `where`: Expression?
    if components.count >= 6 {
      `where` = try parseExpression(components: Array(components.suffix(from: 5)), tokenParser: parser)
    } else {
      `where` = nil
    }
    return ForNode(resolvable: filter, loopVariables: loopVariables, nodes: forNodes, emptyNodes:emptyNodes, where: `where`)
  }

  init(resolvable: Resolvable, loopVariables: [String], nodes:[NodeType], emptyNodes:[NodeType], where: Expression? = nil) {
    self.resolvable = resolvable
    self.loopVariables = loopVariables
    self.nodes = nodes
    self.emptyNodes = emptyNodes
    self.where = `where`
  }

  func push<Result>(value: Any, context: Context, closure: () throws -> (Result)) rethrows -> Result {
    if loopVariables.isEmpty {
      return try context.push() {
        return try closure()
      }
    }

    if let value = value as? (Any, Any) {
      let first = loopVariables[0]

      if loopVariables.count == 2 {
        let second = loopVariables[1]

        return try context.push(dictionary: [first: value.0, second: value.1]) {
          return try closure()
        }
      }

      return try context.push(dictionary: [first: value.0]) {
        return try closure()
      }
    }

    return try context.push(dictionary: [loopVariables.first!: value]) {
      return try closure()
    }
  }

  func render(_ context: Context) throws -> String {
    guard let resolved = try resolvable.resolve(context) else { return "" }

    var values: [Any]

    if let dictionary = resolved as? [String: Any], !dictionary.isEmpty {
      values = dictionary.map { ($0.key, $0.value) }
    } else if let array = resolved as? [Any] {
      if loopVariables.count == 2 {
        values = array.enumerated().map({ ($0.offset, $0.element) })
      } else {
        values = array
      }
    } else if let range = resolved as? CountableClosedRange<Int> {
      values = Array(range)
    } else if let range = resolved as? CountableRange<Int> {
      values = Array(range)
    } else {
      let mirror = Mirror(reflecting: resolved)
      switch mirror.displayStyle {
      case .tuple?:
        values = Array(mirror.children)
      default:
        values = []
      }
    }

    if let `where` = self.where {
      values = try values.filter({ item -> Bool in
        return try push(value: item, context: context) {
          try `where`.evaluate(context: context)
        }
      })
    }

    if !values.isEmpty {
      let count = values.count
      var result = ""
      
      for (index, item) in values.enumerated() {
        let forContext: [String: Any] = [
          "first": index == 0,
          "last": index == (count - 1),
          "counter": index + 1,
          "counter0": index,
          ]
        
        result += try context.push(dictionary: ["forloop": forContext]) {
          return try push(value: item, context: context) {
            try renderNodes(nodes, context)
          }
        }
        
        if context[LoopTerminationNode.break.terminator] as? Bool ?? false {
          context[LoopTerminationNode.break.terminator] = nil
          break
        }
        if context[LoopTerminationNode.continue.terminator] as? Bool ?? false {
          context[LoopTerminationNode.continue.terminator] = nil
        }
      }
      return result
    }

    return try context.push {
      try renderNodes(emptyNodes, context)
    }
  }
}

struct LoopTerminationNode: NodeType {
  static let `break` = LoopTerminationNode(name: "break")
  static let `continue` = LoopTerminationNode(name: "continue")
  
  let name: String
  var terminator: String {
    return "forloop_\(name)"
  }

  private init(name: String) {
    self.name = name
  }
  
  static func parse(_ parser:TokenParser, token:Token) throws -> LoopTerminationNode {
    guard token.components().count == 1 else {
      throw TemplateSyntaxError("'\(token.contents)' does not accept parameters")
    }
    guard parser.hasOpenedForTag() else {
      throw TemplateSyntaxError("'\(token.contents)' can be used only inside loop body")
    }
    return LoopTerminationNode(name: token.contents)
  }
  
  func render(_ context: Context) throws -> String {
    guard let forLoopIndex = context.dictionaries.enumerated().flatMap({ i, c in
      c["forloop"] != nil ? i : nil
    }).max() else { return "" }
    context.dictionaries[forLoopIndex - 1][terminator] = true
    
    return ""
  }

}

extension TokenParser {
  
  func hasOpenedForTag() -> Bool {
    var hasOpenedFor = 0
    for parsedToken in parsedTokens.reversed() {
      if case .block = parsedToken {
        if parsedToken.components().first == "endfor" { hasOpenedFor -= 1  }
        if parsedToken.components().first == "for" { hasOpenedFor += 1 }
      }
    }
    return hasOpenedFor > 0
  }
  
}
