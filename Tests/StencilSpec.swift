import Spectre
import Stencil


class CustomNode : NodeType {
  func render(context:Context) throws -> String {
    return "Hello World"
  }
}


describe("Stencil") {
  $0.it("can render the README example") {
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
    let result = try template.render(context)

    let fixture = "There are 2 articles.\n" +
      "\n" +
      "    - Migrating from OCUnit to XCTest by Kyle Fuller.\n" +
      "    - Memory Management with ARC by Kyle Fuller.\n" +
    "\n"

    try expect(result) == fixture
  }

  $0.it("can render a custom template tag") {
    let templateString = "{% custom %}"
    let template = Template(templateString: templateString)

    let namespace = Namespace()
    namespace.registerTag("custom") { parser, token in
      return CustomNode()
    }

    let result = try template.render(namespace: namespace)
    try expect(result) == "Hello World"
  }

  $0.it("can render a simple custom tag") {
    let templateString = "{% custom %}"
    let template = Template(templateString: templateString)

    let namespace = Namespace()
    namespace.registerSimpleTag("custom") { context in
      return "Hello World"
    }

    try expect(try template.render(namespace: namespace)) == "Hello World"
  }
}
