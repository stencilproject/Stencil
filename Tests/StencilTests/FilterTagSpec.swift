import XCTest
import Spectre
import Stencil

class FilterTagTests: XCTestCase {
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

      $0.it("can render filters with arguments") {
        let ext = Extension()
        ext.registerFilter("split", filter: {
          return ($0 as! String).components(separatedBy: $1[0] as! String)
        })
        let env = Environment(extensions: [ext])
        let result = try env.renderTemplate(string: """
        {% filter split:","|join:";"  %}{{ items|join:"," }}{% endfilter %}
        """, context: ["items": [1, 2]])
        try expect(result) == "1;2"
      }

      $0.it("can render filters with quote as an argument") {
        let ext = Extension()
        ext.registerFilter("replace", filter: {
          print($1[0] as! String)
          return ($0 as! String).replacingOccurrences(of: $1[0] as! String, with: $1[1] as! String)
        })
        let env = Environment(extensions: [ext])
        let result = try env.renderTemplate(string: """
          {% filter replace:'"',"" %}{{ items|join:"," }}{% endfilter %}
          """, context: ["items": ["\"1\"", "\"2\""]])
        try expect(result) == "1,2"
      }
      
      $0.it("can render filter with shorthand syntax") {
        let template = Template(templateString: "{% uppercase %}Test{% enduppercase %}")
        let result = try template.render()
        try expect(result) == "TEST"
      }

      $0.it("can render multiple filters with shorthand syntax") {
        let ext = Extension()
        ext.registerFilter("split", filter: {
          return ($0 as! String).components(separatedBy: $1[0] as! String)
        })
        let env = Environment(extensions: [ext])
        let result = try env.renderTemplate(string: """
        {% split:","|join:";"  %}{{ items|join:"," }}{% endsplit %}
        """, context: ["items": [1, 2]])
        try expect(result) == "1;2"
      }
    }
  }
}
