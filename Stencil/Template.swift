//
//  Template.swift
//  Stencil
//
//  Created by Kyle Fuller on 23/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

import Foundation

public class Template {
    let nodes:[Node]

    public convenience init(named:String) {
        self.init(named:named, inBundle:nil)
    }

    public convenience init(named:String, inBundle bundle:NSBundle?) {
        var url:NSURL?

        if let bundle = bundle {
            url = bundle.URLForResource(named, withExtension: nil)
        } else {
            url = NSBundle.mainBundle().URLForResource(named, withExtension: nil)
        }

        self.init(URL:url!)
    }

    public convenience init(URL:NSURL) {
        var error:NSError?
        let templateString = NSString.stringWithContentsOfURL(URL, encoding: NSUTF8StringEncoding, error: &error)
        self.init(templateString:templateString)
    }

    public init(templateString:String) {
        let lexer = Lexer(templateString: templateString)
        let tokens = lexer.tokenize()
        let parser = TokenParser(tokens: tokens)
        nodes = parser.parse()
    }

    public func render(context:Context) -> (string:String?, error:Error?) {
        return renderNodes(nodes, context)
    }
}
