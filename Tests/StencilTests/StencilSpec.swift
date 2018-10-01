import XCTest
import Spectre
import Stencil

fileprivate struct CustomNode : NodeType {
  let token: Token?
  func render(_ context:Context) throws -> String {
    return "Hello World"
  }
}

fileprivate struct Article {
  let title: String
  let author: String
}

class StencilTests: XCTestCase {
  func testStencil() {
    describe("Stencil") {
      let exampleExtension = Extension()

      exampleExtension.registerSimpleTag("simpletag") { context in
        return "Hello World"
      }

      exampleExtension.registerTag("customtag") { parser, token in
        return CustomNode(token: token)
      }

      let environment = Environment(extensions: [exampleExtension])

      $0.it("can render the README example") {

        let templateString = """
          There are {{ articles.count }} articles.

          {% for article in articles %}\
              - {{ article.title }} by {{ article.author }}.
          {% endfor %}
          """

        let context = [
          "articles": [
            Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
            Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
          ]
        ]

        let template = Template(templateString: templateString)
        let result = try template.render(context)

        try expect(result) == """
          There are 2 articles.

              - Migrating from OCUnit to XCTest by Kyle Fuller.
              - Memory Management with ARC by Kyle Fuller.

          """
      }

      $0.it("can render a custom template tag") {
        let result = try environment.renderTemplate(string: "{% customtag %}")
        try expect(result) == "Hello World"
      }

      $0.it("can render a simple custom tag") {
        let result = try environment.renderTemplate(string: "{% simpletag %}")
        try expect(result) == "Hello World"
      }
    }
  }
}
