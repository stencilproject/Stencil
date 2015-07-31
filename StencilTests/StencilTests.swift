import Foundation
import XCTest
import Stencil
import CatchingFire

class CustomNode : Node {
  func render(context:Context) -> String {
    return "Hello World"
  }
}

class StencilTests: XCTestCase {
  func testReadmeExample() {
    let templateString = "There are {{ articles.count }} articles.\n" +
      "\n" +
      "{% for article in articles %}" +
      "    - {{ article.title }} by {{ article.author }}.\n" +
    "{% endfor %}\n"

    let context = Context(dictionary: [
      "articles": [
        [ "title": "Migrating from OCUnit to XCTest", "author": "Kyle Fuller" ],
        [ "title": "Memory Management with ARC", "author": "Kyle Fuller" ],
      ]
      ])

    let template = Template(templateString:templateString)
    AssertNoThrow {
      let result = try template.render(context)

      let fixture = "There are 2 articles.\n" +
        "\n" +
        "    - Migrating from OCUnit to XCTest by Kyle Fuller.\n" +
        "    - Memory Management with ARC by Kyle Fuller.\n" +
      "\n"

      XCTAssertEqual(result, fixture)
    }
  }

  func testCustomTag() {
    let templateString = "{% custom %}"
    let template = Template(templateString:templateString)

    template.parser.registerTag("custom") { parser, token in
      return CustomNode()
    }

    AssertNoThrow {
      let result = try template.render()
      XCTAssertEqual(result, "Hello World")
    }
  }

  func testSimpleCustomTag() {
    let templateString = "{% custom %}"
    let template = Template(templateString:templateString)

    template.parser.registerSimpleTag("custom") { context in
      return "Hello World"
    }

    AssertNoThrow {
      let result = try template.render()
      XCTAssertEqual(result, "Hello World")
    }
  }
}
