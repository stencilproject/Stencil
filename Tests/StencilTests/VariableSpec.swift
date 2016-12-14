import Foundation
import Spectre
@testable import Stencil


#if os(OSX)
@objc class Object : NSObject {
  let title = "Hello World"
}
#endif

fileprivate struct Person {
  let name: String
}

fileprivate struct Article {
  let author: Person
}

fileprivate struct PostError : Error, Equatable, CustomStringConvertible {
  let description:String

  init(_ description:String) {
    self.description = description
  }
}

fileprivate func ==(lhs:PostError, rhs:PostError) -> Bool {
  return lhs.description == rhs.description
}

fileprivate struct Post: Normalizable {
  let title: String?
  
  func normalize() throws -> Any? {
    if let title = title {
      return "Post '\(title)'"
    } else {
      throw PostError("Cannot normalize a Post with no title")
    }
  }
}

func testVariable() {
  describe("Variable") {
    let context = Context(dictionary: [
      "name": "Kyle",
      "contacts": ["Katie", "Carlton"],
      "profiles": [
        "github": "kylef",
      ],
      "article": Article(author: Person(name: "Kyle")),
      "post": Post(title: "How not to throw an error"),
      "postWithoutTitle": Post(title: nil)
    ])

#if os(OSX)
    context["object"] = Object()
#endif

    $0.it("can resolve a string literal with double quotes") {
      let variable = Variable("\"name\"")
      let result = try variable.resolve(context) as? String
      try expect(result) == "name"
    }

    $0.it("can resolve a string literal with single quotes") {
      let variable = Variable("'name'")
      let result = try variable.resolve(context) as? String
      try expect(result) == "name"
    }

    $0.it("can resolve an integer literal") {
      let variable = Variable("5")
      let result = try variable.resolve(context) as? Number
      try expect(result) == 5
    }

    $0.it("can resolve an float literal") {
      let variable = Variable("3.14")
      let result = try variable.resolve(context) as? Number
      try expect(result) == 3.14
    }

    $0.it("can resolve a string variable") {
      let variable = Variable("name")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Kyle"
    }

    $0.it("can resolve an item from a dictionary") {
      let variable = Variable("profiles.github")
      let result = try variable.resolve(context) as? String
      try expect(result) == "kylef"
    }

    $0.it("can resolve an item from an array via it's index") {
      let variable = Variable("contacts.0")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Katie"

        let variable1 = Variable("contacts.1")
        let result1 = try variable1.resolve(context) as? String
        try expect(result1) == "Carlton"
    }

    $0.it("can resolve an item from an array via unknown index") {
      let variable = Variable("contacts.5")
      let result = try variable.resolve(context) as? String
      try expect(result).to.beNil()

      let variable1 = Variable("contacts.-5")
      let result1 = try variable1.resolve(context) as? String
      try expect(result1).to.beNil()
    }

    $0.it("can resolve the first item from an array") {
      let variable = Variable("contacts.first")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Katie"
    }

    $0.it("can resolve the last item from an array") {
      let variable = Variable("contacts.last")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Carlton"
    }

    $0.it("can resolve a property with reflection") {
      let variable = Variable("article.author.name")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Kyle"
    }

#if os(OSX)
    $0.it("can resolve a value via KVO") {
      let variable = Variable("object.title")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Hello World"
    }
#endif

    $0.it("can normalize without issue") {
      let variable = Variable("post")
      let result = try variable.resolve(context) as? String
      try expect(result) == "Post 'How not to throw an error'"
    }
    
    $0.it("can throw during normalize") {
      let variable = Variable("postWithoutTitle")
      let error = PostError("Cannot normalize a Post with no title")
      try expect(try variable.resolve(context)).toThrow(error)
    }
  }
}
