//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
@testable import Stencil
import XCTest

final class NowNodeTests: XCTestCase {
  func testParsing() {
    it("parses default format without any now arguments") {
      #if os(Linux)
      throw skip()
      #else
      let tokens: [Token] = [ .block(value: "now", at: .unknown) ]
      let parser = TokenParser(tokens: tokens, environment: Environment())

      let nodes = try parser.parse()
      let node = nodes.first as? NowNode
      try expect(nodes.count) == 1
      try expect(node?.format.variable) == "\"yyyy-MM-dd 'at' HH:mm\""
      #endif
    }

    it("parses now with a format") {
      #if os(Linux)
      throw skip()
      #else
      let tokens: [Token] = [ .block(value: "now \"HH:mm\"", at: .unknown) ]
      let parser = TokenParser(tokens: tokens, environment: Environment())
      let nodes = try parser.parse()
      let node = nodes.first as? NowNode
      try expect(nodes.count) == 1
      try expect(node?.format.variable) == "\"HH:mm\""
      #endif
    }
  }

  func testRendering() {
    it("renders the date") {
      #if os(Linux)
      throw skip()
      #else
      let node = NowNode(format: Variable("\"yyyy-MM-dd\""))

      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      let date = formatter.string(from: Date())

      try expect(try node.render(Context())) == date
      #endif
    }
  }
}
