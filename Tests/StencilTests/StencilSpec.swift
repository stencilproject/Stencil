import Spectre
import Stencil


fileprivate class CustomNode : NodeType {
  func render(_ context:Context) throws -> String {
    return "Hello World"
  }
}


fileprivate struct Article {
  let title: String
  let author: String
}


func testStencil() {
  describe("Stencil") {
    let exampleExtension = Extension()

    exampleExtension.registerSimpleTag("simpletag") { context in
      return "Hello World"
    }

    exampleExtension.registerTag("customtag") { parser, token in
      return CustomNode()
    }

    let environment = Environment(extensions: [exampleExtension])

    $0.it("can render the README example") {

      let templateString = "There are {{ articles.count }} articles.\n" +
        "\n" +
        "{% for article in articles %}" +
        "    - {{ article.title }} by {{ article.author }}.\n" +
        "{% endfor %}\n"

      let context = [
        "articles": [
          Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
          Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
        ]
      ]

      let template = Template(templateString: templateString)
      let result = try template.render(context)

      let fixture = "There are 2 articles.\n" +
        "\n" +
        "    - Migrating from OCUnit to XCTest by Kyle Fuller.\n" +
        "    - Memory Management with ARC by Kyle Fuller.\n"

      try expect(result) == fixture
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
