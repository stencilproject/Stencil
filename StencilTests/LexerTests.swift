//
//  LexerTests.swift
//  Stencil
//
//  Created by Kyle Fuller on 24/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

import Cocoa
import XCTest
import Stencil

class LexerTests: XCTestCase {

    func testTokenizeText() {
        let lexer = Lexer(templateString:"Hello World")
        let tokens = lexer.tokenize()

        XCTAssertEqual(tokens.count, 1)
        XCTAssertEqual(tokens.first!, Token.Text(value: "Hello World"))
    }

}
