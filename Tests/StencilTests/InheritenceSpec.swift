import Spectre
import Stencil
import PathKit


func testInheritence() {
  describe("Inheritence") {
    let path = Path(#file) + ".." + "fixtures"
    let loader = FileSystemLoader(paths: [path])

    $0.it("can inherit from another template") {
      let context = Context(dictionary: ["loader": loader])
      let template = try loader.loadTemplate(name: "child.html")
      try expect(try template?.render(context)) == "Header\nChild"
    }

    $0.it("can inherit from another template inheriting from another template") {
      let context = Context(dictionary: ["loader": loader])
      let template = try loader.loadTemplate(name: "child-child.html")
      try expect(try template?.render(context)) == "Child Child Header\nChild"
    }
  }
}
