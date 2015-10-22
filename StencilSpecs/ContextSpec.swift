import Spectre
import Stencil


describe("Context") {
  var context: Context!

  $0.before {
    context = Context(dictionary: ["name": "Kyle"])
  }

  $0.it("allows you to get a value via subscripting") {
    try expect(context["name"] as? String) == "Kyle"
  }

  $0.it("allows you to set a value via subscripting") {
    context["name"] = "Katie"

    try expect(context["name"] as? String) == "Katie"
  }

  $0.it("allows you to remove a value via subscripting") {
    context["name"] = nil

    try expect(context["name"]).to.beNil()
  }

  $0.it("allows you to retrieve a value from a parent") {
    context.push()

    try expect(context["name"] as? String) == "Kyle"
  }

  $0.it("allows you to override a parent's value") {
    context.push()
    context["name"] = "Katie"

    try expect(context["name"] as? String) == "Katie"
  }

  $0.it("allows you to pop to restore previous state") {
    context.push()
    context["name"] = "Katie"
    context.pop()

    try expect(context["name"] as? String) == "Kyle"
  }

  $0.it("allows you to push a dictionary onto the stack") {
    context.push(["name": "Katie"])
    try expect(context["name"] as? String) == "Katie"
  }
}
