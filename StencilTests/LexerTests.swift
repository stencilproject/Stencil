import Foundation
import XCTest
import Stencil

class LexerTests: XCTestCase {

    func testTokenizeText() {
        let lexer = Lexer(templateString:"Hello World")
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first!, Token.Text(value: "Hello World"))
    }

    func testTokenizeComment() {
        let lexer = Lexer(templateString:"{# Comment #}")
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first!, Token.Comment(value: "Comment"))
    }

    func testTokenizeVariable() {
        let lexer = Lexer(templateString:"{{ Variable }}")
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first!, Token.Variable(value: "Variable"))
    }

    func testTokenizeMixture() {
        let lexer = Lexer(templateString:"My name is {{ name }}.")
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 3)
        XCTAssertEqual(tokens[0], Token.Text(value: "My name is "))
        XCTAssertEqual(tokens[1], Token.Variable(value: "name"))
        XCTAssertEqual(tokens[2], Token.Text(value: "."))
    }

    func testTokenizeTwoVariables() { // Don't be greedy
        let lexer = Lexer(templateString:"{{ thing }}{{ name }}")
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 2)
        XCTAssertEqual(tokens[0], Token.Variable(value: "thing"))
        XCTAssertEqual(tokens[1], Token.Variable(value: "name"))
    }

}
