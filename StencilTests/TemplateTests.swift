import Foundation
import XCTest
import Stencil

class TemplateTests: XCTestCase {

    func testTemplate() {
        let context = Context(dictionary: [ "name": "Kyle" ])
        let template = Template(templateString: "Hello World")
        let result = template.render(context)
        XCTAssertEqual(result, StencilResult.Success("Hello World"))
    }

}
