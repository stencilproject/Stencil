//
//  Lexer.swift
//  Stencil
//
//  Created by Kyle Fuller on 24/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

import Foundation

public struct Lexer {
    public let templateString:String

    public init(templateString:String) {
        self.templateString = templateString
    }

    public func tokenize() -> [Token] {
        return [Token.Text(value: templateString)]
    }
}
