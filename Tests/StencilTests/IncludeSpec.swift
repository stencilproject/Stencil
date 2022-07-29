//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import PathKit
import Spectre
@testable import Stencil
import XCTest

final class IncludeTests: XCTestCase {
  private let path = Path(#file as String) + ".." + "fixtures"
  private lazy var loader = FileSystemLoader(paths: [path])
  private lazy var environment = Environment(loader: loader)

  func testParsing() {
    it("throws an error when no template is given") {
      let tokens: [Token] = [ .block(value: "include", at: .unknown) ]
      let parser = TokenParser(tokens: tokens, environment: Environment())

      let error = TemplateSyntaxError(reason: """
        'include' tag requires one argument, the template file to be included. \
        A second optional argument can be used to specify the context that will \
        be passed to the included file
        """, token: tokens.first)
      try expect(try parser.parse()).toThrow(error)
    }

    it("can parse a valid include block") {
      let tokens: [Token] = [ .block(value: "include \"test.html\"", at: .unknown) ]
      let parser = TokenParser(tokens: tokens, environment: Environment())

      let nodes = try parser.parse()
      let node = nodes.first as? IncludeNode
      try expect(nodes.count) == 1
      try expect(node?.templateName) == Variable("\"test.html\"")
    }
  }

  func testRendering() {
    it("throws an error when rendering without a loader") {
      let node = IncludeNode(templateName: Variable("\"test.html\""), token: .block(value: "", at: .unknown))

      do {
        _ = try node.render(Context())
      } catch {
        try expect("\(error)") == "Template named `test.html` does not exist. No loaders found"
      }
    }

    it("throws an error when it cannot find the included template") {
      let node = IncludeNode(templateName: Variable("\"unknown.html\""), token: .block(value: "", at: .unknown))

      do {
        _ = try node.render(Context(environment: self.environment))
      } catch {
        try expect("\(error)".hasPrefix("Template named `unknown.html` does not exist in loader")).to.beTrue()
      }
    }

    it("successfully renders a found included template") {
      let node = IncludeNode(templateName: Variable("\"test.html\""), token: .block(value: "", at: .unknown))
      let context = Context(dictionary: ["target": "World"], environment: self.environment)
      let value = try node.render(context)
      try expect(value) == "Hello World!"
    }

    it("successfully passes context") {
      let template = Template(templateString: """
        {% include "test.html" child %}
        """)
      let context = Context(dictionary: ["child": ["target": "World"]], environment: self.environment)
      let value = try template.render(context)
      try expect(value) == "Hello World!"
    }
  }
}
