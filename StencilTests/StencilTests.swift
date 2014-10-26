//
//  StencilTests.swift
//  StencilTests
//
//  Created by Kyle Fuller on 23/10/2014.
//  Copyright (c) 2014 Cocode. All rights reserved.
//

import Cocoa
import XCTest
import Stencil

class StencilTests: XCTestCase {
    func testReadmeExample() {
        let templateString = "There are {{ articles.count }} articles.\n" +
            "\n" +
            "{% for article in articles %}" +
            "    - {{ article.title }} by {{ article.author }}.\n" +
            "{% endfor %}\n"

        let context = Context(dictionary: [
            "articles": [
                [ "title": "Migrating from OCUnit to XCTest", "author": "Kyle Fuller" ],
                [ "title": "Memory Management with ARC", "author": "Kyle Fuller" ],
            ]
        ])

        let template = Template(templateString:templateString)
        let result = template.render(context)

        let fixture = "There are 2 articles.\n" +
            "\n" +
            "    - Migrating from OCUnit to XCTest by Kyle Fuller.\n" +
            "    - Memory Management with ARC by Kyle Fuller.\n" +
            "\n"

        XCTAssertEqual(result, Result.Success(string: fixture))
    }
}
