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

func any<Element>(elements:[Element], closure:(Element -> Bool)) -> Element? {
  for element in elements {
    if closure(element) {
      return element
    }
  }

  return nil
}

class ExtendsNode : Node {
  let templateName:String
  let blocks:[String:BlockNode]

  class func parse(parser:TokenParser, token:Token) -> TokenParser.Result {
    let bits = token.contents.componentsSeparatedByString("\"")

    if bits.count != 3 {
      return .Error(error:NodeError(token: token, message: "Tag takes one argument, the template file to be extended"))
    }

    switch parser.parse() {
    case .Success(let nodes):
      if (any(nodes) { ($0 as? ExtendsNode) != nil }) != nil {
        return .Error(error:"'extends' cannot appear more than once in the same template")
      }

      let blockNodes = filter(nodes) { node in node is BlockNode }

      let nodes = reduce(blockNodes, [String:BlockNode](), { (accumulator, node:Node) -> [String:BlockNode] in
        let node = (node as! BlockNode)
        var dict = accumulator
        dict[node.name] = node
        return dict
      })

      return .Success(node:ExtendsNode(templateName: bits[1], blocks: nodes))
    case .Error(let error):
      return .Error(error:error)
    }
  }

  init(templateName:String, blocks:[String:BlockNode]) {
    self.templateName = templateName
    self.blocks = blocks
  }

  func render(context: Context) -> Result {
    if let loader =  context["loader"] as? TemplateLoader {
      if let template = loader.loadTemplate(templateName) {
        let blockContext = BlockContext(blocks: blocks)
        context.push([BlockContext.contextKey: blockContext])
        let result = template.render(context)
        context.pop()
        return result
      }

      let paths:String = join(", ", loader.paths.map { path in
        return path.description
        })
      let error = "Template '\(templateName)' not found in \(paths)"
      return .Error(error)
    }

    let error = "Template loader not in context"
    return .Error(error)
  }
}

class BlockNode : Node {
  let name:String
  let nodes:[Node]

  class func parse(parser:TokenParser, token:Token) -> TokenParser.Result {
    let bits = token.components()

    if bits.count != 2 {
      return .Error(error:NodeError(token: token, message: "Tag takes one argument, the template file to be included"))
    }

    let blockName = bits[1]
    var nodes = [Node]()

    switch parser.parse(until(["endblock"])) {
    case .Success(let blockNodes):
      nodes = blockNodes
    case .Error(let error):
      return .Error(error: error)
    }

    return .Success(node:BlockNode(name:blockName, nodes:nodes))
  }

  init(name:String, nodes:[Node]) {
    self.name = name
    self.nodes = nodes
  }

  func render(context: Context) -> Result {
    if let blockContext = context[BlockContext.contextKey] as? BlockContext {
      if let node = blockContext.pop(name) {
        return node.render(context)
      }
    }

    return renderNodes(nodes, context)
  }
}
