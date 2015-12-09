import Foundation
import Spectre
import Stencil


describe("NowNode") {
  $0.describe("parsing") {
    $0.it("parses default format without any now arguments") {
      let tokens = [ Token.Block(value: "now") ]
      let parser = TokenParser(tokens: tokens, namespace: Namespace())

      let nodes = try parser.parse()
      let node = nodes.first as? NowNode
      try expect(nodes.count) == 1
      try expect(node?.format.variable) == "\"yyyy-MM-dd 'at' HH:mm\""
    }

    $0.it("parses now with a format") {
      let tokens = [ Token.Block(value: "now \"HH:mm\"") ]
      let parser = TokenParser(tokens: tokens, namespace: Namespace())
      let nodes = try parser.parse()
      let node = nodes.first as? NowNode
      try expect(nodes.count) == 1
      try expect(node?.format.variable) == "\"HH:mm\""
    }
  }

  $0.describe("rendering") {
    $0.it("renders the date") {
      let node = NowNode(format: Variable("\"yyyy-MM-dd\""))

      let formatter = NSDateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      let date = formatter.stringFromDate(NSDate())

      try expect(try node.render(Context())) == date
    }
  }
}
