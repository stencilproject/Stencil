import XCTest
import Spectre
import Stencil
import PathKit

class TemplateLoaderTests: XCTestCase {
  func testTemplateLoader() {
    describe("FileSystemLoader") {
      let path = Path(#file) + ".."  + "fixtures"
      let loader = FileSystemLoader(paths: [path])
      let environment = Environment(loader: loader)

      $0.it("errors when a template cannot be found") {
        try expect(try environment.loadTemplate(name: "unknown.html")).toThrow()
      }

      $0.it("errors when an array of templates cannot be found") {
        try expect(try environment.loadTemplate(names: ["unknown.html", "unknown2.html"])).toThrow()
      }

      $0.it("can load a template from a file") {
        _ = try environment.loadTemplate(name: "test.html")
      }

      $0.it("errors when loading absolute file outside of the selected path") {
        try expect(try environment.loadTemplate(name: "/etc/hosts")).toThrow()
      }

      $0.it("errors when loading relative file outside of the selected path") {
        try expect(try environment.loadTemplate(name: "../LoaderSpec.swift")).toThrow()
      }
    }

    describe("DictionaryLoader") {
      let loader = DictionaryLoader(templates: [
        "index.html": "Hello World"
        ])
      let environment = Environment(loader: loader)

      $0.it("errors when a template cannot be found") {
        try expect(try environment.loadTemplate(name: "unknown.html")).toThrow()
      }

      $0.it("errors when an array of templates cannot be found") {
        try expect(try environment.loadTemplate(names: ["unknown.html", "unknown2.html"])).toThrow()
      }

      $0.it("can load a template from a known templates") {
        _ = try environment.loadTemplate(name: "index.html")
      }

      $0.it("can load a known template from a collection of templates") {
        _ = try environment.loadTemplate(names: ["unknown.html", "index.html"])
      }
    }
  }
}
