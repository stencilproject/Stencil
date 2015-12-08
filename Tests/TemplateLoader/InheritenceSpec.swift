import Spectre
import Stencil
import PathKit


describe("Inheritence") {
  let path = Path(__FILE__) + ".." + ".." + "Tests" + "fixtures"
  let loader = TemplateLoader(paths: [path])

  $0.it("can inherit from another template") {
    let context = Context(dictionary: ["loader": loader])
    let template = loader.loadTemplate("child.html")
    try expect(try template?.render(context)) == "Header\nChild"
  }
}
