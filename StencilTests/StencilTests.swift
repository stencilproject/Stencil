import Foundation
import XCTest
import Stencil

func assertSuccess(result:TokenParser.Results, block:(([Node]) -> ())) {
    switch result {
    case .Success(let nodes):
        block(nodes)
    case .Error(let error):
        XCTAssert(false, "Unexpected error")
    }
}

func assertFailure(result:TokenParser.Results, description:String) {
    switch result {
    case .Success(let nodes):
        XCTAssert(false, "Unexpected error")
    case .Error(let error):
        XCTAssertEqual("\(error)", description)
    }
}

class CustomNode : Node {
    func render(context:Context) -> Result {
        return .Success("Hello World")
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
        let result = template.render(context)

        let fixture = "There are 2 articles.\n" +
            "\n" +
            "    - Migrating from OCUnit to XCTest by Kyle Fuller.\n" +
            "    - Memory Management with ARC by Kyle Fuller.\n" +
            "\n"

        XCTAssertEqual(result, Result.Success(fixture))
    }

    func testCustomTag() {
        let templateString = "{% custom %}"
        let template = Template(templateString:templateString)

        template.parser.registerTag("custom") { parser, token in
            return .Success(node:CustomNode())
        }

        let result = template.render()
        XCTAssertEqual(result, Result.Success("Hello World"))
    }

    func testSimpleCustomTag() {
        let templateString = "{% custom %}"
        let template = Template(templateString:templateString)

        template.parser.registerSimpleTag("custom") { context in
            return .Success("Hello World")
        }

        let result = template.render()
        XCTAssertEqual(result, Result.Success("Hello World"))
    }
}
