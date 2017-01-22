class ForNode : NodeType {
  let resolvable: Resolvable
  let loopVariable:String
  let nodes:[NodeType]
  let emptyNodes: [NodeType]
  let `where`: Expression?

  class func parse(_ parser:TokenParser, token:Token) throws -> NodeType {
    let components = token.components()

    guard components.count >= 2 && components[2] == "in" &&
        (components.count == 4 || (components.count >= 6 && components[4] == "where")) else {
      throw TemplateSyntaxError("'for' statements should use the following 'for x in y where condition' `\(token.contents)`.")
    }

    let loopVariable = components[1]
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
    return ForNode(resolvable: filter, loopVariable: loopVariable, nodes: forNodes, emptyNodes:emptyNodes, where: `where`)
  }

  init(resolvable: Resolvable, loopVariable:String, nodes:[NodeType], emptyNodes:[NodeType], where: Expression? = nil) {
    self.resolvable = resolvable
    self.loopVariable = loopVariable
    self.nodes = nodes
    self.emptyNodes = emptyNodes
    self.where = `where`
  }

  func render(_ context: Context) throws -> String {
    let values = try resolvable.resolve(context)

    if var values = values as? [Any], values.count > 0 {
      if let `where` = self.where {
        values = try values.filter({ item -> Bool in
          return try context.push(dictionary: [loopVariable: item]) { () -> Bool in
            try `where`.evaluate(context: context)
          }
        })
      }
      if values.count > 0 {
        let count = values.count
        return try values.enumerated().map { index, item in
          let forContext: [String: Any] = [
            "first": index == 0,
            "last": index == (count - 1),
            "counter": index + 1,
          ]

          return try context.push(dictionary: [loopVariable: item, "forloop": forContext]) {
          try renderNodes(nodes, context)
          }
        }.joined(separator: "")
      }
    }

    return try context.push {
      try renderNodes(emptyNodes, context)
    }
  }
}
