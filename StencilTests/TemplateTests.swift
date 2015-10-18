import Foundation
import XCTest
import Stencil

class TemplateTests: XCTestCase {
  func testTemplate() {
    let context = Context(dictionary: [ "name": "Kyle" ])
    let template = Template(templateString: "Hello World")
    let result = try? template.render(context)
    XCTAssertEqual(result, "Hello World")
  }

  func testTemplateNamedInBundle() {
    let testBundle = NSBundle(forClass: self.dynamicType)
    let template = try? Template(named: "test.html", inBundle: testBundle)
    let context = Context(dictionary: [ "target": "Kyle" ])

    XCTAssertNotNil(template)
    let result = try? template!.render(context)
    XCTAssertEqual(result, "Hello Kyle!")
  }


  func testTemplateWithNSURL() {
    let testBundle = NSBundle(forClass: self.dynamicType)
    let URL = testBundle.URLForResource("test", withExtension: "html")
    XCTAssertNotNil(URL)
    let template = try? Template(URL: URL!)
    let context = Context(dictionary: [ "target": "Kyle" ])

    XCTAssertNotNil(template)
    let result = try? template!.render(context)
    XCTAssertEqual(result, "Hello Kyle!")
  }
}
