import Foundation

class BlockContext {
  class var contextKey:String { return "block_context" }

  var blocks:[String:BlockNode]

  init(blocks:[String:BlockNode]) {
    self.blocks = blocks
  }

  func pop(blockName:String) -> BlockNode? {
    return blocks.removeValueForKey(blockName)
  }
}

class ExtendsNode : Node {
  let templateName:String
  let blocks:[String:BlockNode]

  class func parse(parser:TokenParser, token:Token) throws -> Node {
    let bits = token.contents.componentsSeparatedByString("\"")

    if bits.count != 3 {
      throw ParseError(cause: .InvalidArgumentCount, token: token, message: "Tag takes one argument, the template file to be extended")
    }

    let nodes = try parser.parse()
    if nodes.contains({ $0 is ExtendsNode }) {
      throw ParseError(cause: .ExtendsUsedMoreThanOnce, token: token, message: "'extends' cannot appear more than once in the same template")
    }

    let blockNodes = nodes.filter { $0 is BlockNode }

    let combinedBlockNodes = blockNodes.reduce([String:BlockNode](), combine: { (var dict, node) in
      let node = node as! BlockNode
      dict[node.name] = node
      return dict
    })

    return ExtendsNode(templateName: bits[1], blocks: combinedBlockNodes)
  }

  init(templateName:String, blocks:[String:BlockNode]) {
    self.templateName = templateName
    self.blocks = blocks
  }

  func render(context: Context) throws -> String {
    return try renderTemplate(context, templateName: templateName) { (context, template) in
      let blockContext = BlockContext(blocks: self.blocks)
      context.push([BlockContext.contextKey: blockContext])
      let result = try template.render(context)
      context.pop()
      return result
    }
  }
}

class BlockNode : Node {
  let name:String
  let nodes:[Node]

  class func parse(parser:TokenParser, token:Token) throws -> Node {
    let bits = token.components()

    if bits.count != 2 {
      throw ParseError(cause: .InvalidArgumentCount, token: token, message: "Tag takes one argument, the template file to be included")
    }

    let blockName = bits[1]
    let nodes = try parser.parse(until(["endblock"]))

    return BlockNode(name:blockName, nodes:nodes)
  }

  init(name:String, nodes:[Node]) {
    self.name = name
    self.nodes = nodes
  }

  func render(context: Context) throws -> String {
    if let blockContext = context[BlockContext.contextKey] as? BlockContext {
      if let node = blockContext.pop(name) {
        return try node.render(context)
      }
    }

    return try renderNodes(nodes, context: context)
  }
}
