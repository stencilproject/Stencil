import Foundation
import Spectre
import Stencil


@objc class Object : NSObject {
  let title = "Hello World"
}


describe("Variable") {
  let context = Context(dictionary: [
    "name": "Kyle",
    "contacts": ["Katie", "Carlton"],
    "profiles": [
      "github": "kylef",
    ],
    "object": Object(),
  ])

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

  $0.it("can resolve a value via KVO") {
    let variable = Variable("object.title")
    let result = try variable.resolve(context) as? String
    try expect(result) == "Hello World"
  }
}
