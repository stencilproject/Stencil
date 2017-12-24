import Spectre
import Stencil


func testFilterTag() {
  describe("Filter Tag") {
    $0.it("allows you to use a filter") {
      let template = Template(templateString: "{% filter uppercase %}Test{% endfilter %}")
      let result = try template.render()
      try expect(result) == "TEST"
    }

    $0.it("allows you to chain filters") {
      let template = Template(templateString: "{% filter lowercase|capitalize %}TEST{% endfilter %}")
      let result = try template.render()
      try expect(result) == "Test"
    }

    $0.it("errors without a filter") {
      let template = Template(templateString: "Some {% filter %}Test{% endfilter %}")
      try expect(try template.render()).toThrow()
    }

  }
}
