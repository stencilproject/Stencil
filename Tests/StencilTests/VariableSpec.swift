//
// Stencil
// Copyright © 2022 Stencil
// MIT Licence
//

import Spectre
@testable import Stencil
import XCTest

final class VariableTests: XCTestCase {
  private let context: Context = {
    let ext = Extension()
    ext.registerFilter("incr") { arg in
      (arg.flatMap { toNumber(value: $0) } ?? 0) + 1
    }
    let environment = Environment(extensions: [ext])

    var context = Context(dictionary: [
      "name": "Kyle",
      "contacts": ["Katie", "Carlton"],
      "profiles": [
        "github": "kylef"
      ],
      "counter": [
        "count": "kylef"
      ],
      "article": Article(author: Person(name: "Kyle")),
      "blog": Blog(),
      "tuple": (one: 1, two: 2),
      "dynamic": [
        "enum": DynamicEnum.someValue,
        "struct": DynamicStruct()
      ]
    ], environment: environment)
    #if os(OSX)
    context["object"] = Object()
    #endif
    return context
  }()

  func testLiterals() {
    it("can resolve a string literal with double quotes") {
      let variable = Variable("\"name\"")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "name"
    }

    it("can resolve a string literal with one double quote") {
      let variable = Variable("\"")
      let result = try variable.resolve(self.context) as? String
      try expect(result).to.beNil()
    }

    it("can resolve a string literal with single quotes") {
      let variable = Variable("'name'")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "name"
    }

    it("can resolve a string literal with one single quote") {
      let variable = Variable("'")
      let result = try variable.resolve(self.context) as? String
      try expect(result).to.beNil()
    }

    it("can resolve an integer literal") {
      let variable = Variable("5")
      let result = try variable.resolve(self.context) as? Int
      try expect(result) == 5
    }

    it("can resolve an float literal") {
      let variable = Variable("3.14")
      let result = try variable.resolve(self.context) as? Number
      try expect(result) == 3.14
    }

    it("can resolve boolean literal") {
      try expect(Variable("true").resolve(self.context) as? Bool) == true
      try expect(Variable("false").resolve(self.context) as? Bool) == false
      try expect(Variable("0").resolve(self.context) as? Int) == 0
      try expect(Variable("1").resolve(self.context) as? Int) == 1
    }
  }

  func testVariable() {
    it("can resolve a string variable") {
      let variable = Variable("name")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "Kyle"
    }
  }

  func testDictionary() {
    it("can resolve an item from a dictionary") {
      let variable = Variable("profiles.github")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "kylef"
    }

    it("can get the count of a dictionary") {
      let variable = Variable("profiles.count")
      let result = try variable.resolve(self.context) as? Int
      try expect(result) == 1
    }
  }

  func testArray() {
    it("can resolve an item from an array via it's index") {
      let variable = Variable("contacts.0")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "Katie"

      let variable1 = Variable("contacts.1")
      let result1 = try variable1.resolve(self.context) as? String
      try expect(result1) == "Carlton"
    }

    it("can resolve an item from an array via unknown index") {
      let variable = Variable("contacts.5")
      let result = try variable.resolve(self.context) as? String
      try expect(result).to.beNil()

      let variable1 = Variable("contacts.-5")
      let result1 = try variable1.resolve(self.context) as? String
      try expect(result1).to.beNil()
    }

    it("can resolve the first item from an array") {
      let variable = Variable("contacts.first")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "Katie"
    }

    it("can resolve the last item from an array") {
      let variable = Variable("contacts.last")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "Carlton"
    }
  }

  func testDynamicMemberLookup() {
    it("can resolve dynamic member lookup") {
      let variable = Variable("dynamic.struct.test")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "this is a dynamic response"
    }

    it("can resolve dynamic enum rawValue") {
      let variable = Variable("dynamic.enum.rawValue")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "this is raw value"
    }
  }

  func testReflection() {
    it("can resolve a property with reflection") {
      let variable = Variable("article.author.name")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "Kyle"
    }

    it("can resolve a value via reflection") {
      let variable = Variable("blog.articles.0.author.name")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "Kyle"
    }

    it("can resolve a superclass value via reflection") {
      let variable = Variable("blog.url")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "blog.com"
    }

    it("can resolve optional variable property using reflection") {
      let variable = Variable("blog.featuring.author.name")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "Jhon"
    }
  }

  func testKVO() {
    #if os(OSX)
    it("can resolve a value via KVO") {
      let variable = Variable("object.title")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "Hello World"
    }

    it("can resolve a superclass value via KVO") {
      let variable = Variable("object.name")
      let result = try variable.resolve(self.context) as? String
      try expect(result) == "Foo"
    }

    it("does not crash on KVO") {
      let variable = Variable("object.fullname")
      let result = try variable.resolve(self.context) as? String
      try expect(result).to.beNil()
    }
    #endif
  }

  func testTuple() {
    it("can resolve tuple by index") {
      let variable = Variable("tuple.0")
      let result = try variable.resolve(self.context) as? Int
      try expect(result) == 1
    }

    it("can resolve tuple by label") {
      let variable = Variable("tuple.two")
      let result = try variable.resolve(self.context) as? Int
      try expect(result) == 2
    }
  }

  func testOptional() {
    it("does not render Optional") {
      var array: [Any?] = [1, nil]
      array.append(array)
      let context = Context(dictionary: ["values": array])

      try expect(VariableNode(variable: "values").render(context)) == "[1, nil, [1, nil]]"
      try expect(VariableNode(variable: "values.1").render(context)) == ""
    }
  }

  func testSubscripting() {
    it("can resolve a property subscript via reflection") {
      try self.context.push(dictionary: ["property": "name"]) {
        let variable = Variable("article.author[property]")
        let result = try variable.resolve(self.context) as? String
        try expect(result) == "Kyle"
      }
    }

    it("can subscript an array with a valid index") {
      try self.context.push(dictionary: ["property": 0]) {
        let variable = Variable("contacts[property]")
        let result = try variable.resolve(self.context) as? String
        try expect(result) == "Katie"
      }
    }

    it("can subscript an array with an unknown index") {
      try self.context.push(dictionary: ["property": 5]) {
        let variable = Variable("contacts[property]")
        let result = try variable.resolve(self.context) as? String
        try expect(result).to.beNil()
      }
    }

    #if os(OSX)
    it("can resolve a subscript via KVO") {
      try self.context.push(dictionary: ["property": "name"]) {
        let variable = Variable("object[property]")
        let result = try variable.resolve(self.context) as? String
        try expect(result) == "Foo"
      }
    }
    #endif

    it("can resolve an optional subscript via reflection") {
      try self.context.push(dictionary: ["property": "featuring"]) {
        let variable = Variable("blog[property].author.name")
        let result = try variable.resolve(self.context) as? String
        try expect(result) == "Jhon"
      }
    }
  }

  func testMultipleSubscripting() {
    it("can resolve multiple subscripts") {
      try self.context.push(dictionary: [
        "prop1": "articles",
        "prop2": 0,
        "prop3": "name"
      ]) {
        let variable = Variable("blog[prop1][prop2].author[prop3]")
        let result = try variable.resolve(self.context) as? String
        try expect(result) == "Kyle"
      }
    }

    it("can resolve nested subscripts") {
      try self.context.push(dictionary: [
        "prop1": "prop2",
        "ref": ["prop2": "name"]
      ]) {
        let variable = Variable("article.author[ref[prop1]]")
        let result = try variable.resolve(self.context) as? String
        try expect(result) == "Kyle"
      }
    }

    it("throws for invalid keypath syntax") {
      try self.context.push(dictionary: ["prop": "name"]) {
        let samples = [
          ".",
          "..",
          ".test",
          "test..test",
          "[prop]",
          "article.author[prop",
          "article.author[[prop]",
          "article.author[prop]]",
          "article.author[]",
          "article.author[[]]",
          "article.author[prop][]",
          "article.author[prop]comments",
          "article.author[.]"
        ]

        for lookup in samples {
          let variable = Variable(lookup)
          try expect(variable.resolve(self.context)).toThrow()
        }
      }
    }
  }

  func testRangeVariable() {
    func makeVariable(_ token: String) throws -> RangeVariable? {
      let token = Token.variable(value: token, at: .unknown)
      return try RangeVariable(token.contents, environment: context.environment, containedIn: token)
    }

    it("can resolve closed range as array") {
      let result = try makeVariable("1...3")?.resolve(self.context) as? [Int]
      try expect(result) == [1, 2, 3]
    }

    it("can resolve decreasing closed range as reversed array") {
      let result = try makeVariable("3...1")?.resolve(self.context) as? [Int]
      try expect(result) == [3, 2, 1]
    }

    it("can use filter on range variables") {
      let result = try makeVariable("1|incr...3|incr")?.resolve(self.context) as? [Int]
      try expect(result) == [2, 3, 4]
    }

    it("throws when left value is not int") {
      let template: Template = "{% for i in k...j %}{{ i }}{% endfor %}"
      try expect(try template.render(Context(dictionary: ["j": 3, "k": "1"]))).toThrow()
    }

    it("throws when right value is not int") {
      let variable = try makeVariable("k...j")
      try expect(try variable?.resolve(Context(dictionary: ["j": "3", "k": 1]))).toThrow()
    }

    it("throws is left range value is missing") {
      try expect(makeVariable("...1")).toThrow()
    }

    it("throws is right range value is missing") {
      try expect(makeVariable("1...")).toThrow()
    }
  }
}

// MARK: - Helpers

#if os(OSX)
@objc
class Superclass: NSObject {
  @objc let name = "Foo"
}
@objc
class Object: Superclass {
  @objc let title = "Hello World"
}
#endif

private struct Person {
  let name: String
}

private struct Article {
  let author: Person
}

private class WebSite {
  let url: String = "blog.com"
}

private class Blog: WebSite {
  let articles: [Article] = [Article(author: Person(name: "Kyle"))]
  let featuring: Article? = Article(author: Person(name: "Jhon"))
}

@dynamicMemberLookup
private struct DynamicStruct: DynamicMemberLookup {
  subscript(dynamicMember member: String) -> Any? {
    member == "test" ? "this is a dynamic response" : nil
  }
}

private enum DynamicEnum: String, DynamicMemberLookup {
  case someValue = "this is raw value"
}
