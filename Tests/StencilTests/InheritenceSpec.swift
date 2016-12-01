import Spectre
import Stencil
import PathKit


func testInheritence() {
  describe("Inheritence") {
    let path = Path(#file) + ".." + "fixtures"
    let loader = FileSystemLoader(paths: [path])
    let environment = Environment(loader: loader)

    $0.it("can inherit from another template") {
      let template = try environment.loadTemplate(name: "child.html")
      try expect(try template.render()) == "Header\nChild"
    }

    $0.it("can inherit from another template inheriting from another template") {
      let template = try environment.loadTemplate(name: "child-child.html")
      try expect(try template.render()) == "Child Child Header\nChild"
    }
  }
}
