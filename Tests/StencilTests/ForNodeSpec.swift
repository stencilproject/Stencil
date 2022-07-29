//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
@testable import Stencil
import XCTest

final class ForNodeTests: XCTestCase {
  private let context = Context(dictionary: [
    "items": [1, 2, 3],
    "anyItems": [1, 2, 3] as [Any],
    // swiftlint:disable:next legacy_objc_type
    "nsItems": NSArray(array: [1, 2, 3]),
    "emptyItems": [Int](),
    "dict": [
      "one": "I",
      "two": "II"
    ],
    "tuples": [(1, 2, 3), (4, 5, 6)]
  ])

  func testForNode() {
    it("renders the given nodes for each item") {
      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(self.context)) == "123"
    }

    it("renders the given empty nodes when no items found item") {
      let node = ForNode(
        resolvable: Variable("emptyItems"),
        loopVariables: ["item"],
        nodes: [VariableNode(variable: "item")],
        emptyNodes: [TextNode(text: "empty")]
      )
      try expect(try node.render(self.context)) == "empty"
    }

    it("renders a context variable of type Array<Any>") {
      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let node = ForNode(resolvable: Variable("anyItems"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(self.context)) == "123"
    }

    #if os(OSX)
    it("renders a context variable of type NSArray") {
      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let node = ForNode(resolvable: Variable("nsItems"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(self.context)) == "123"
    }
    #endif

    it("can render a filter with spaces") {
      let template = Template(templateString: """
        {% for article in ars | default: a, b , articles %}\
        - {{ article.title }} by {{ article.author }}.
        {% endfor %}
        """)
      let context = Context(dictionary: [
        "articles": [
          Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
          Article(title: "Memory Management with ARC", author: "Kyle Fuller")
        ]
      ])
      let result = try template.render(context)

      try expect(result) == """
        - Migrating from OCUnit to XCTest by Kyle Fuller.
        - Memory Management with ARC by Kyle Fuller.

        """
    }
  }

  func testLoopMetadata() {
    it("renders the given nodes while providing if the item is first in the context") {
      let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.first")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(self.context)) == "1true2false3false"
    }

    it("renders the given nodes while providing if the item is last in the context") {
      let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.last")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(self.context)) == "1false2false3true"
    }

    it("renders the given nodes while providing item counter") {
      let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.counter")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(self.context)) == "112233"
    }

    it("renders the given nodes while providing item counter") {
      let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.counter0")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(self.context)) == "102132"
    }

    it("renders the given nodes while providing loop length") {
      let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.length")]
      let node = ForNode(resolvable: Variable("items"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])
      try expect(try node.render(self.context)) == "132333"
    }
  }

  func testWhereExpression() {
    it("renders the given nodes while filtering items using where expression") {
      let nodes: [NodeType] = [VariableNode(variable: "item"), VariableNode(variable: "forloop.counter")]
      let parser = TokenParser(tokens: [], environment: Environment())
      let `where` = try parser.compileExpression(components: ["item", ">", "1"], token: .text(value: "", at: .unknown))
      let node = ForNode(
        resolvable: Variable("items"),
        loopVariables: ["item"],
        nodes: nodes,
        emptyNodes: [],
        where: `where`
      )
      try expect(try node.render(self.context)) == "2132"
    }

    it("renders the given empty nodes when all items filtered out with where expression") {
      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let emptyNodes: [NodeType] = [TextNode(text: "empty")]
      let parser = TokenParser(tokens: [], environment: Environment())
      let `where` = try parser.compileExpression(components: ["item", "==", "0"], token: .text(value: "", at: .unknown))
      let node = ForNode(
        resolvable: Variable("emptyItems"),
        loopVariables: ["item"],
        nodes: nodes,
        emptyNodes: emptyNodes,
        where: `where`
      )
      try expect(try node.render(self.context)) == "empty"
    }
  }

  func testArrayOfTuples() {
    it("can iterate over all tuple values") {
      let template = Template(templateString: """
        {% for first,second,third in tuples %}\
        {{ first }}, {{ second }}, {{ third }}
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        1, 2, 3
        4, 5, 6

        """
    }

    it("can iterate with less number of variables") {
      let template = Template(templateString: """
        {% for first,second in tuples %}\
        {{ first }}, {{ second }}
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        1, 2
        4, 5

        """
    }

    it("can use _ to skip variables") {
      let template = Template(templateString: """
        {% for first,_,third in tuples %}\
        {{ first }}, {{ third }}
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        1, 3
        4, 6

        """
    }

    it("throws when number of variables is more than number of tuple values") {
      let template = Template(templateString: """
        {% for key,value,smth in dict %}{% endfor %}
        """)
      try expect(template.render(self.context)).toThrow()
    }
  }

  func testIterateDictionary() {
    it("can iterate over dictionary") {
      let template = Template(templateString: """
        {% for key, value in dict %}\
        {{ key }}: {{ value }},\
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        one: I,two: II,
        """
    }

    it("renders supports iterating over dictionary") {
      let nodes: [NodeType] = [
        VariableNode(variable: "key"),
        TextNode(text: ",")
      ]
      let emptyNodes: [NodeType] = [TextNode(text: "empty")]
      let node = ForNode(
        resolvable: Variable("dict"),
        loopVariables: ["key"],
        nodes: nodes,
        emptyNodes: emptyNodes
      )

      try expect(node.render(self.context)) == """
        one,two,
        """
    }

    it("renders supports iterating over dictionary with values") {
      let nodes: [NodeType] = [
        VariableNode(variable: "key"),
        TextNode(text: "="),
        VariableNode(variable: "value"),
        TextNode(text: ",")
      ]
      let emptyNodes: [NodeType] = [TextNode(text: "empty")]
      let node = ForNode(
        resolvable: Variable("dict"),
        loopVariables: ["key", "value"],
        nodes: nodes,
        emptyNodes: emptyNodes
      )

      try expect(node.render(self.context)) == """
        one=I,two=II,
        """
    }
  }

  func testIterateUsingMirroring() {
    let nodes: [NodeType] = [
      VariableNode(variable: "label"),
      TextNode(text: "="),
      VariableNode(variable: "value"),
      TextNode(text: "\n")
    ]
    let node = ForNode(
      resolvable: Variable("item"),
      loopVariables: ["label", "value"],
      nodes: nodes,
      emptyNodes: []
    )

    it("can iterate over struct properties") {
      let context = Context(dictionary: [
        "item": MyStruct(string: "abc", number: 123)
      ])
      try expect(node.render(context)) == """
        string=abc
        number=123

        """
    }

    it("can iterate tuple items") {
      let context = Context(dictionary: [
        "item": (one: 1, two: "dva")
      ])
      try expect(node.render(context)) == """
        one=1
        two=dva

        """
    }

    it("can iterate over class properties") {
      let context = Context(dictionary: [
        "item": MySubclass("child", "base", 1)
      ])
      try expect(node.render(context)) == """
        childString=child
        baseString=base
        baseInt=1

        """
    }
  }

  func testIterateRange() {
    it("renders a context variable of type CountableClosedRange<Int>") {
      let context = Context(dictionary: ["range": 1...3])
      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let node = ForNode(resolvable: Variable("range"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])

      try expect(try node.render(context)) == "123"
    }

    it("renders a context variable of type CountableRange<Int>") {
      let context = Context(dictionary: ["range": 1..<4])
      let nodes: [NodeType] = [VariableNode(variable: "item")]
      let node = ForNode(resolvable: Variable("range"), loopVariables: ["item"], nodes: nodes, emptyNodes: [])

      try expect(try node.render(context)) == "123"
    }

    it("can iterate in range of variables") {
      let template: Template = "{% for i in 1...j %}{{ i }}{% endfor %}"
      try expect(try template.render(Context(dictionary: ["j": 3]))) == "123"
    }
  }

  func testHandleInvalidInput() throws {
    let token = Token.block(value: "for i", at: .unknown)
    let parser = TokenParser(tokens: [token], environment: Environment())
    let error = TemplateSyntaxError(
      reason: "'for' statements should use the syntax: `for <x> in <y> [where <condition>]`.",
      token: token
    )
    try expect(try parser.parse()).toThrow(error)
  }

  func testBreak() {
    it("can break from loop") {
      let template = Template(templateString: """
        {% for item in items %}\
        {{ item }}{% break %}\
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        1
        """
    }

    it("can break from inner node") {
      let template = Template(templateString: """
        {% for item in items %}\
        {{ item }}\
        {% if forloop.first %}<{% break %}>{% endif %}!\
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        1<
        """
    }

    it("does not allow break outside loop") {
      let template = Template(templateString: "{% for item in items %}{% endfor %}{% break %}")
      let error = self.expectedSyntaxError(
        token: "break",
        template: template,
        description: "'break' can be used only inside loop body"
      )
      try expect(template.render(self.context)).toThrow(error)
    }
  }

  func testBreakNested() {
    it("breaks outer loop") {
      let template = Template(templateString: """
        {% for item in items %}\
        outer: {{ item }}
        {% for item in items %}\
        inner: {{ item }}
        {% endfor %}\
        {% break %}\
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        outer: 1
        inner: 1
        inner: 2
        inner: 3

        """
    }

    it("breaks inner loop") {
      let template = Template(templateString: """
        {% for item in items %}\
        outer: {{ item }}
        {% for item in items %}\
        inner: {{ item }}
        {% break %}\
        {% endfor %}\
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        outer: 1
        inner: 1
        outer: 2
        inner: 1
        outer: 3
        inner: 1

        """
    }
  }

  func testBreakLabeled() {
    it("breaks labeled loop") {
      let template = Template(templateString: """
        {% outer: for item in items %}\
        outer: {{ item }}
        {% for item in items %}\
        {% break outer %}\
        inner: {{ item }}
        {% endfor %}\
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        outer: 1

        """
    }

    it("throws when breaking with unknown label") {
      let template = Template(templateString: """
        {% outer: for item in items %}
        {% break inner %}
        {% endfor %}
        """)
      try expect(template.render(self.context)).toThrow()
    }
  }

  func testContinue() {
    it("can continue loop") {
      let template = Template(templateString: """
        {% for item in items %}\
        {{ item }}{% continue %}!\
        {% endfor %}
        """)
      try expect(template.render(self.context)) == "123"
    }

    it("can continue from inner node") {
      let template = Template(templateString: """
        {% for item in items %}\
        {% if forloop.last %}<{% continue %}>{% endif %}!\
        {{ item }}\
        {% endfor %}
        """)
      try expect(template.render(self.context)) == "!1!2<"
    }

    it("does not allow continue outside loop") {
      let template = Template(templateString: "{% for item in items %}{% endfor %}{% continue %}")
      let error = self.expectedSyntaxError(
        token: "continue",
        template: template,
        description: "'continue' can be used only inside loop body"
      )
      try expect(template.render(self.context)).toThrow(error)
    }
  }

  func testContinueNested() {
    it("breaks outer loop") {
      let template = Template(templateString: """
        {% for item in items %}\
        {% for item in items %}\
        inner: {{ item }}\
        {% endfor %}
        {% continue %}
        outer: {{ item }}
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        inner: 1inner: 2inner: 3
        inner: 1inner: 2inner: 3
        inner: 1inner: 2inner: 3

        """
    }

    it("breaks inner loop") {
      let template = Template(templateString: """
        {% for item in items %}\
        {% for item in items %}\
        {% continue %}\
        inner: {{ item }}
        {% endfor %}\
        outer: {{ item }}
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        outer: 1
        outer: 2
        outer: 3

        """
    }
  }

  func testContinueLabeled() {
    it("continues labeled loop") {
      let template = Template(templateString: """
        {% outer: for item in items %}\
        {% for item in items %}\
        inner: {{ item }}
        {% continue outer %}\
        {% endfor %}\
        outer: {{ item }}
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        inner: 1
        inner: 1
        inner: 1

        """
    }

    it("throws when continuing with unknown label") {
      let template = Template(templateString: """
        {% outer: for item in items %}
        {% continue inner %}
        {% endfor %}
        """)
      try expect(template.render(self.context)).toThrow()
    }
  }

  func testAccessLabeled() {
    it("can access labeled outer loop context from inner loop") {
      let template = Template(templateString: """
        {% outer: for item in 1...2 %}\
        {% for item in items %}\
        {{ forloop.counter }}-{{ forloop.outer.counter }},\
        {% endfor %}---\
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        1-1,2-1,3-1,---1-2,2-2,3-2,---
        """
    }

    it("can access labeled outer loop from double inner loop") {
      let template = Template(templateString: """
        {% outer: for item in 1...2 %}{% for item in 1...2 %}\
        {% for item in items %}\
        {{ forloop.counter }}-{{ forloop.outer.counter }},\
        {% endfor %}---{% endfor %}
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        1-1,2-1,3-1,---1-1,2-1,3-1,---
        1-2,2-2,3-2,---1-2,2-2,3-2,---

        """
    }

    it("can access two labeled outer loop contexts from inner loop") {
      let template = Template(templateString: """
        {% outer1: for item in 1...2 %}{% outer2: for item in 1...2 %}\
        {% for item in items %}\
        {{ forloop.counter }}-{{ forloop.outer2.counter }}-{{ forloop.outer1.counter }},\
        {% endfor %}---{% endfor %}
        {% endfor %}
        """)
      try expect(template.render(self.context)) == """
        1-1-1,2-1-1,3-1-1,---1-2-1,2-2-1,3-2-1,---
        1-1-2,2-1-2,3-1-2,---1-2-2,2-2-2,3-2-2,---

        """
    }
  }
}

// MARK: - Helpers

private struct MyStruct {
  let string: String
  let number: Int
}

private struct Article {
  let title: String
  let author: String
}

private class MyClass {
  var baseString: String
  var baseInt: Int
  init(_ string: String, _ int: Int) {
    baseString = string
    baseInt = int
  }
}

private class MySubclass: MyClass {
  var childString: String
  init(_ childString: String, _ string: String, _ int: Int) {
    self.childString = childString
    super.init(string, int)
  }
}
