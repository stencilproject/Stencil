//
//  Template.swift
//  Stencil
//
//  Created by Kyle Fuller on 23/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

import Foundation

public class Template {
    let parser:TokenParser

    public convenience init?(named:String) {
        self.init(named:named, inBundle:nil)
    }

    public convenience init?(named:String, inBundle bundle:NSBundle?) {
        var url:NSURL?

        if let bundle = bundle {
            url = bundle.URLForResource(named, withExtension: nil)
        } else {
            url = NSBundle.mainBundle().URLForResource(named, withExtension: nil)
        }

        self.init(URL:url!)
    }

    public convenience init?(URL:NSURL) {
        var error:NSError?
        let maybeTemplateString = NSString(contentsOfURL: URL, encoding: NSUTF8StringEncoding, error: &error)
        if let templateString = maybeTemplateString {
            self.init(templateString:templateString)
        } else {
            self.init(templateString:"")
            return nil
        }
    }

    public init(templateString:String) {
        let lexer = Lexer(templateString: templateString)
        let tokens = lexer.tokenize()
        parser = TokenParser(tokens: tokens)
    }

    public func render(context:Context) -> Result {
        let (nodes, error) = parser.parse()

        if let error = error {
            return .Error(error: error)
        } else if let nodes = nodes {
            let result = renderNodes(nodes, context)
            if let string = result.0 {
                return .Success(string: string)
            } else {
                return .Error(error: result.1!)
            }
        }
        return .Success(string: "")
    }
}
