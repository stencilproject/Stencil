import Foundation
import XCTest
import Stencil
import PathKit

class TemplateLoaderTests: XCTestCase {

    func testLoadingUnknownTemplate() {
        let loader = TemplateLoader(paths:[])
        XCTAssertNil(loader.loadTemplate("unknown.html"))
    }

    func testLoadingUnknownTemplates() {
        let loader = TemplateLoader(paths:[])
        XCTAssertNil(loader.loadTemplate(["unknown.html", "unknown2.html"]))
    }

    func testLoadingTemplate() {
        let path = (Path(__FILE__) + Path("..")).absolute()
        let loader = TemplateLoader(paths: [path])
        XCTAssertTrue(loader.loadTemplate("test.html") != nil)
    }

}
