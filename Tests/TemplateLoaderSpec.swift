import Spectre
import Stencil
import PathKit


describe("TemplateLoader") {
  let path = Path(__FILE__) + ".." + ".." + "Tests" + "fixtures"
  let loader = TemplateLoader(paths: [path])

  $0.it("returns nil when a template cannot be found") {
    try expect(loader.loadTemplate("unknown.html")).to.beNil()
  }

  $0.it("returns nil when an array of templates cannot be found") {
    try expect(loader.loadTemplate(["unknown.html", "unknown2.html"])).to.beNil()
  }

  $0.it("can load a template from a file") {
    if loader.loadTemplate("test.html") == nil {
      throw failure("didn't find the template")
    }
  }
}
