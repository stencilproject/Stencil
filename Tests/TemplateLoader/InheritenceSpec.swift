import Spectre
import Stencil
import PathKit


func testInheritence() {
  describe("Inheritence") {
    let path = Path(__FILE__) + ".." + ".." + "fixtures"
    let loader = TemplateLoader(paths: [path])

    $0.it("can inherit from another template") {
      let context = Context(dictionary: ["loader": loader])
      let template = loader.loadTemplate("child.html")
      try expect(try template?.render(context)) == "Header\nChild"
    }
  }
}
