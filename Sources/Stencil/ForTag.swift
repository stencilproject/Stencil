//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Foundation

class ForNode: NodeType {
  let resolvable: Resolvable
  let loopVariables: [String]
  let nodes: [NodeType]
  let emptyNodes: [NodeType]
  let `where`: Expression?
  let label: String?
  let token: Token?

  class func parse(_ parser: TokenParser, token: Token) throws -> NodeType {
    var components = token.components

    var label: String?
    if components.first?.hasSuffix(":") == true {
      label = String(components.removeFirst().dropLast())
    }

    func hasToken(_ token: String, at index: Int) -> Bool {
      components.count > (index + 1) && components[index] == token
    }

    func endsOrHasToken(_ token: String, at index: Int) -> Bool {
      components.count == index || hasToken(token, at: index)
    }

    guard hasToken("in", at: 2) && endsOrHasToken("where", at: 4) else {
      throw TemplateSyntaxError("'for' statements should use the syntax: `for <x> in <y> [where <condition>]`.")
    }

    let loopVariables = components[1]
      .split(separator: ",")
      .map(String.init)
      .map { $0.trim(character: " ") }

    let resolvable = try parser.compileResolvable(components[3], containedIn: token)

    let `where` = hasToken("where", at: 4)
      ? try parser.compileExpression(components: Array(components.suffix(from: 5)), token: token)
      : nil

    let forNodes = try parser.parse(until(["endfor", "empty"]))

    guard let token = parser.nextToken() else {
      throw TemplateSyntaxError("`endfor` was not found.")
    }

    var emptyNodes = [NodeType]()
    if token.contents == "empty" {
      emptyNodes = try parser.parse(until(["endfor"]))
      _ = parser.nextToken()
    }

    return ForNode(
      resolvable: resolvable,
      loopVariables: loopVariables,
      nodes: forNodes,
      emptyNodes: emptyNodes,
      where: `where`,
      label: label,
      token: token
    )
  }

  init(
    resolvable: Resolvable,
    loopVariables: [String],
    nodes: [NodeType],
    emptyNodes: [NodeType],
    where: Expression? = nil,
    label: String? = nil,
    token: Token? = nil
  ) {
    self.resolvable = resolvable
    self.loopVariables = loopVariables
    self.nodes = nodes
    self.emptyNodes = emptyNodes
    self.where = `where`
    self.label = label
    self.token = token
  }

  func render(_ context: Context) throws -> String {
    var values = try resolve(context)

    if let `where` = self.where {
      values = try values.filter { item -> Bool in
        try push(value: item, context: context) {
          try `where`.evaluate(context: context)
        }
      }
    }

    if !values.isEmpty {
      let count = values.count
      var result = ""

      // collect parent loop contexts
      let parentLoopContexts = (context["forloop"] as? [String: Any])?
        .filter { ($1 as? [String: Any])?["label"] != nil } ?? [:]

      for (index, item) in zip(0..., values) {
        var forContext: [String: Any] = [
          "first": index == 0,
          "last": index == (count - 1),
          "counter": index + 1,
          "counter0": index,
          "length": count
        ]
        if let label = label {
          forContext["label"] = label
          forContext[label] = forContext
        }
        forContext.merge(parentLoopContexts) { lhs, _ in lhs }

        var shouldBreak = false
        result += try context.push(dictionary: ["forloop": forContext]) {
          defer {
            // if outer loop should be continued we should break from current loop
            if let shouldContinueLabel = context[LoopTerminationNode.continueContextKey] as? String {
              shouldBreak = shouldContinueLabel != label || label == nil
            } else {
              shouldBreak = context[LoopTerminationNode.breakContextKey] != nil
            }
          }
          return try push(value: item, context: context) {
            try renderNodes(nodes, context)
          }
        }

        if shouldBreak {
          break
        }
      }

      return result
    } else {
      return try context.push {
        try renderNodes(emptyNodes, context)
      }
    }
  }

  private func push<Result>(value: Any, context: Context, closure: () throws -> (Result)) throws -> Result {
    if loopVariables.isEmpty {
      return try context.push {
        try closure()
      }
    }

    let valueMirror = Mirror(reflecting: value)
    if case .tuple? = valueMirror.displayStyle {
      if loopVariables.count > Int(valueMirror.children.count) {
        throw TemplateSyntaxError("Tuple '\(value)' has less values than loop variables")
      }
      var variablesContext = [String: Any]()
      valueMirror.children.prefix(loopVariables.count).enumerated().forEach { offset, element in
        if loopVariables[offset] != "_" {
          variablesContext[loopVariables[offset]] = element.value
        }
      }

      return try context.push(dictionary: variablesContext) {
        try closure()
      }
    }

    return try context.push(dictionary: [loopVariables.first ?? "": value]) {
      try closure()
    }
  }

  private func resolve(_ context: Context) throws -> [Any] {
    let resolved = try resolvable.resolve(context)

    var values: [Any]
    if let dictionary = resolved as? [String: Any], !dictionary.isEmpty {
      values = dictionary.sorted { $0.key < $1.key }
    } else if let array = resolved as? [Any] {
      values = array
    } else if let range = resolved as? CountableClosedRange<Int> {
      values = Array(range)
    } else if let range = resolved as? CountableRange<Int> {
      values = Array(range)
    } else if let resolved = resolved {
      let mirror = Mirror(reflecting: resolved)
      switch mirror.displayStyle {
      case .struct, .tuple:
        values = Array(mirror.children)
      case .class:
        var children = Array(mirror.children)
        var currentMirror: Mirror? = mirror
        while let superclassMirror = currentMirror?.superclassMirror {
          children.append(contentsOf: superclassMirror.children)
          currentMirror = superclassMirror
        }
        values = Array(children)
      default:
        values = []
      }
    } else {
      values = []
    }

    return values
  }
}

struct LoopTerminationNode: NodeType {
  static let breakContextKey = "_internal_forloop_break"
  static let continueContextKey = "_internal_forloop_continue"

  let name: String
  let label: String?
  let token: Token?

  var contextKey: String {
    "_internal_forloop_\(name)"
  }

  private init(name: String, label: String? = nil, token: Token? = nil) {
    self.name = name
    self.label = label
    self.token = token
  }

  static func parse(_ parser: TokenParser, token: Token) throws -> LoopTerminationNode {
    let components = token.components

    guard components.count <= 2 else {
      throw TemplateSyntaxError("'\(token.contents)' can accept only one parameter")
    }
    guard parser.hasOpenedForTag() else {
      throw TemplateSyntaxError("'\(token.contents)' can be used only inside loop body")
    }

    return LoopTerminationNode(name: components[0], label: components.count == 2 ? components[1] : nil, token: token)
  }

  func render(_ context: Context) throws -> String {
    let offset = zip(0..., context.dictionaries).reversed().first { _, dictionary in
      guard let forContext = dictionary["forloop"] as? [String: Any],
        dictionary["forloop"] != nil else { return false }

      if let label = label {
        return label == forContext["label"] as? String
      } else {
        return true
      }
    }?.0

    if let offset = offset {
      context.dictionaries[offset][contextKey] = label ?? true
    } else if let label = label {
      throw TemplateSyntaxError("No loop labeled '\(label)' is currently running")
    } else {
      throw TemplateSyntaxError("No loop is currently running")
    }

    return ""
  }
}

private extension TokenParser {
  func hasOpenedForTag() -> Bool {
    var openForCount = 0
    for parsedToken in parsedTokens.reversed() where parsedToken.kind == .block {
      if parsedToken.components.first == "endfor" { openForCount -= 1 }
      if parsedToken.components.first == "for" { openForCount += 1 }
    }
    return openForCount > 0
  }
}
