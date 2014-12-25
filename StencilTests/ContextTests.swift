import Foundation
import XCTest
import Stencil

class ContextTests: XCTestCase {
    var context:Context!

    override func setUp() {
        context = Context(dictionary: ["name": "Kyle"])
    }

    func testItAllowsYouToRetrieveAValue() {
        let name = context["name"] as String!
        XCTAssertEqual(name, "Kyle")
    }

    func testItAllowsYouToSetValue() {
        context["name"] = "Katie"

        let name = context["name"] as String!
        XCTAssertEqual(name, "Katie")
    }

    func testItAllowsYouToRemoveAValue() {
        context["name"] = nil
        XCTAssertNil(context["name"])
    }

    func testItAllowsYouToRetrieveAValueFromParent() {
        context.push()

        let name = context["name"] as String!
        XCTAssertEqual(name, "Kyle")
    }

    func testItAllowsYouToOverideAParentVariable() {
        context.push()
        context["name"] = "Katie"

        let name = context["name"] as String!
        XCTAssertEqual(name, "Katie")
    }

    func testShowAllowYouToPopVariablesRestoringPreviousState() {
        context.push()
        context["name"] = "Katie"
        context.pop()

        let name = context["name"] as String!
        XCTAssertEqual(name, "Kyle")
    }

    func testItAllowsYouToPushADictionaryToTheStack() {
        context.push(["name": "Katie"])

        let name = context["name"] as String!
        XCTAssertEqual(name, "Katie")
    }

    func testItAllowsYouToCompareTwoContextsForEquality() {
        let otherContext = Context(dictionary: ["name": "Kyle"])

        XCTAssertEqual(otherContext, context )
    }
}
