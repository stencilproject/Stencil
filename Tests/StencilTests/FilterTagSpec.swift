import Spectre
import Stencil
import XCTest

final class FilterTagTests: XCTestCase {
  func testFilterTag() {
    it("allows you to use a filter") {
      let template = Template(templateString: "{% filter uppercase %}Test{% endfilter %}")
      let result = try template.render()
      try expect(result) == "TEST"
    }

    it("allows you to chain filters") {
      let template = Template(templateString: "{% filter lowercase|capitalize %}TEST{% endfilter %}")
      let result = try template.render()
      try expect(result) == "Test"
    }

    it("errors without a filter") {
      let template = Template(templateString: "Some {% filter %}Test{% endfilter %}")
      try expect(try template.render()).toThrow()
    }

    it("can render filters with arguments") {
      let ext = Extension()
      ext.registerFilter("split") {
        guard let value = $0 as? String,
          let argument = $1.first as? String else { return $0 }
        return value.components(separatedBy: argument)
      }
      let env = Environment(extensions: [ext])
      let result = try env.renderTemplate(string: """
        {% filter split:","|join:";"  %}{{ items|join:"," }}{% endfilter %}
        """, context: ["items": [1, 2]])
      try expect(result) == "1;2"
    }

    it("can render filters with quote as an argument") {
      let ext = Extension()
      ext.registerFilter("replace") {
        guard let value = $0 as? String,
          $1.count == 2,
          let search = $1.first as? String,
          let replacement = $1.last as? String else { return $0 }
        return value.replacingOccurrences(of: search, with: replacement)
      }
      let env = Environment(extensions: [ext])
      let result = try env.renderTemplate(string: """
        {% filter replace:'"',"" %}{{ items|join:"," }}{% endfilter %}
        """, context: ["items": ["\"1\"", "\"2\""]])
      try expect(result) == "1,2"
    }
  }
}
