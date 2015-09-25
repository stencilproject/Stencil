import Foundation
import XCTest
import Stencil
import PathKit

class InheritenceTests: NodeTests {
  var loader:TemplateLoader!

  override func setUp() {
    super.setUp()

    let path = (Path(__FILE__) + Path("../..")).absolute()
    loader = TemplateLoader(paths: [path])
  }

  func testInheritence() {
    context = Context(dictionary: ["loader": loader])
    let template = loader.loadTemplate("child.html")!
    XCTAssertEqual(try? template.render(context), "Header\nChild")
  }
}

//class BlockNodeTests: NodeTests {
//    func testBlockNodeWithoutChildren() {
//        let context = Context()
//        let block = BlockNode(name:"header", nodes:[TextNode(text: "contents")])
//        let result = block.render(context)
//
//        assertSuccess(result) { rendered in
//            XCTAssertEqual(rendered, "contents")
//        }
//    }
//
//    func testBlockNodeWithChild() {
//        let context = Context()
//        let node = BlockNode(name:"header", nodes:[TextNode(text: "contents")])
//        let childBlock = BlockNode(name: "header", nodes: [TextNode(text: "child contents")])
//        let result = node.render(context)
//
//        assertSuccess(result) { rendered in
//            XCTAssertEqual(rendered, "child contents")
//        }
//    }
//}
