import Spectre
import Stencil
import PathKit


func testTemplateLoader() {
  describe("TemplateLoader") {
    let path = Path(#file) + ".."  + "fixtures"
    let loader = FileSystemLoader(paths: [path])

    $0.it("returns nil when a template cannot be found") {
      try expect(try loader.loadTemplate(name: "unknown.html")).to.beNil()
    }

    $0.it("returns nil when an array of templates cannot be found") {
      try expect(try loader.loadTemplate(names: ["unknown.html", "unknown2.html"])).to.beNil()
    }

    $0.it("can load a template from a file") {
      if try loader.loadTemplate(name: "test.html") == nil {
        throw failure("didn't find the template")
      }
    }
  }
}
