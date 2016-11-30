import Spectre
import Stencil
import PathKit


func testTemplateLoader() {
  describe("FileSystemLoader") {
    let path = Path(#file) + ".."  + "fixtures"
    let loader = FileSystemLoader(paths: [path])

    $0.it("errors when a template cannot be found") {
      try expect(try loader.loadTemplate(name: "unknown.html")).toThrow()
    }

    $0.it("errors when an array of templates cannot be found") {
      try expect(try loader.loadTemplate(names: ["unknown.html", "unknown2.html"])).toThrow()
    }

    $0.it("can load a template from a file") {
      _ = try loader.loadTemplate(name: "test.html")
    }

    $0.it("errors when loading absolute file outside of the selected path") {
      try expect(try loader.loadTemplate(name: "/etc/hosts")).toThrow()
    }

    $0.it("errors when loading relative file outside of the selected path") {
      try expect(try loader.loadTemplate(name: "../LoaderSpec.swift")).toThrow()
    }
  }
}
