import Foundation
import XCTest
import Stencil
import PathKit

class IncludeTests: NodeTests {

  var loader:TemplateLoader!

  override func setUp() {
    super.setUp()

    let path = (Path(__FILE__) + Path("../..")).absolute()
    loader = TemplateLoader(paths: [path])
  }

  // MARK: Parsing

  func testParseMissingTemplate() {
    let tokens = [ Token.Block(value: "include") ]
    let parser = TokenParser(tokens: tokens)

    assertFailure(try parser.parse(), TemplateSyntaxError("'include' tag takes one argument, the template file to be included"))
  }

  func testParse() {
    let tokens = [ Token.Block(value: "include \"test.html\"") ]
    let parser = TokenParser(tokens: tokens)

    assertSuccess(try parser.parse()) { nodes in
      let node = nodes.first as! IncludeNode
      XCTAssertEqual(nodes.count, 1)
      XCTAssertEqual(node.templateName, "test.html")
    }
  }

  // MARK: Render

  func testRenderWithoutLoader() {
    let node = IncludeNode(templateName: "test.html")

    do {
      try node.render(Context())
    } catch {
      XCTAssertEqual("\(error)", "Template loader not in context")
    }
  }

  func testRenderWithoutTemplateNamed() {
    let node = IncludeNode(templateName: "unknown.html")

    do {
      try node.render(Context(dictionary:["loader":loader]))
    } catch {
      XCTAssertTrue("\(error)".hasPrefix("'unknown.html' template not found"))
    }
  }

  func testRender() {
    let node = IncludeNode(templateName: "test.html")
    let value = try? node.render(Context(dictionary:["loader":loader, "target": "World"]))
    XCTAssertEqual(value, "Hello World!")
  }
}
