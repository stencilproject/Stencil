import Foundation
import XCTest
import Stencil

@objc class Object : NSObject {
    let title = "Hello World"
}

class VariableTests: XCTestCase {
    var context:Context!

    override func setUp() {
        context = Context(dictionary: [
            "name": "Kyle",
            "contacts": [ "Katie", "Orta", ],
            "profiles": [ "github": "kylef", ],
            "object": Object(),
        ])
    }

    func testResolvingStringLiteral() {
        let variable = Variable("\"name\"")
        let result = variable.resolve(context) as String!
        XCTAssertEqual(result, "name")
    }

    func testResolvingVariable() {
        let variable = Variable("name")
        let result = variable.resolve(context) as String!
        XCTAssertEqual(result, "Kyle")
    }

    func testResolvingItemFromDictionary() {
        let variable = Variable("profiles.github")
        let result = variable.resolve(context) as String!
        XCTAssertEqual(result, "kylef")
    }

    func testResolvingItemFromArrayWithIndex() {
        let variable = Variable("contacts.0")
        let result = variable.resolve(context) as String!
        XCTAssertEqual(result, "Katie")
    }

    func testResolvingFirstItemFromArray() {
        let variable = Variable("contacts.first")
        let result = variable.resolve(context) as String!
        XCTAssertEqual(result, "Katie")
    }

    func testResolvingLastItemFromArray() {
        let variable = Variable("contacts.last")
        let result = variable.resolve(context) as String!
        XCTAssertEqual(result, "Orta")
    }

    func testResolvingValueViaKVO() {
        let variable = Variable("object.title")
        let result = variable.resolve(context) as String!
        XCTAssertEqual(result, "Hello World")
    }
}
