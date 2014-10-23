Stencil
=======

Stencil is a simple and powerful template language for Swift. It provides a
syntax similar to Django and Jinja2.

### Example

```html+django
There are {{ articles.count }} articles.

{% for article in articles %}
  - {{ article.title }} by {{ article.author }}.
{% endfor %}
```

```swift
let context = Context(dictionary: [
    "articles": [
        [ "title": "Migrating from OCUnit to XCTest", "author": "Kyle Fuller" ],
        [ "title": "Memory Management with ARC", "author": "Kyle Fuller" ],
    ]
])

let template = Template(path:"template.stencil")
let result = template.render(context)

if let error = result.error {
    println("There was a syntax error parsing your template (\(error)).")
}

println("\(result.string)")
```

## License

Stencil is licensed under the BSD license. See [LICENSE](LICENSE) for more
info.

