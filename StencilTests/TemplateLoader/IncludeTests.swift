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

        assertFailure(parser.parse(), "include: Tag takes one argument, the template file to be included")
    }

    func testParse() {
        let tokens = [ Token.Block(value: "include \"test.html\"") ]
        let parser = TokenParser(tokens: tokens)

        assertSuccess(parser.parse()) { nodes in
            let node = nodes.first! as IncludeNode
            XCTAssertEqual(nodes.count, 1)
            XCTAssertEqual(node.templateName, "test.html")
        }
    }

    // MARK: Render

    func testRenderWithoutLoader() {
        let node = IncludeNode(templateName: "test.html")
        let result = node.render(Context())

        switch result {
        case .Success(let string):
            XCTAssert(false, "Unexpected error")
        case .Error(let error):
            XCTAssertEqual("\(error)", "Template loader not in context")
        }
    }

    func testRenderWithoutTemplateNamed() {
        let node = IncludeNode(templateName: "unknown.html")
        let result = node.render(Context(dictionary:["loader":loader]))

        switch result {
        case .Success(let string):
            XCTAssert(false, "Unexpected error")
        case .Error(let error):
            XCTAssertTrue("\(error)".hasPrefix("Template 'unknown.html' not found"))
        }
    }

    func testRender() {
        let node = IncludeNode(templateName: "test.html")
        let result = node.render(Context(dictionary:["loader":loader, "target": "World"]))

        switch result {
        case .Success(let string):
            XCTAssertEqual(string, "Hello World!")
        case .Error(let error):
            XCTAssert(false, "Unexpected error: \(error)")
        }
    }

}
