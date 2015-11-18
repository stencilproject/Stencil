Stencil Architecture
====================

This document outlines the architecture of Stencil and how it works internally.

Stencil uses a three-step process for rendering templates. The first step is tokenising the template into an array of Token’s. Afterwards, the array of token’s are transformed into a collection of Node’s. Once we have a collection of Node’s (objects conforming to the `Node` protocol), we then call `render(context)` on each Node instructing it to render itself inside the given context.

## Token

Token is an enum which has four members. These represent a piece of text, a variable, a comment or a template block. They are parsed using the `TokenParser` which takes the template as a string as input and returns an array of Token’s.

### Values

#### Text

A text token represents a string which will be rendered in the template. For example, a text token with the string `Hello World` will be rendered as such in the output.

#### Variable

A variable token represents a variable inside a context. It will be evaluated and rendered in the output. It is created from the template using `{{ string }}`.

#### Comment

The comment token represents a comment inside the source. It is created using `{# This is a comment #}`.

#### Block

A block represents a template tag. It is created using `{% this is a template block %}` inside a template. The template tag in this case would be called `this`. See “Block Token” below for more information.

### Parsing

A template is parsed using the TokenParser into an array of Token’s. For example:

```html+django
Hello {{ name }}
```

Would be parsed into two tokens. A token representing the string, `Hello ` and a token representing the variable called `name`. So, in Swift it would be represented as follows:

```swift
let tokens = [
  Token.Text("Hello "),
  Token.Variable("name"),
]
```

## Node

Node is a protocol with a single method, to render it inside a context. When rendering a node, it is converted into the output string, or an error if there is a failure. Token’s are converted to Node’s using the `TokenParser` class.

For some Token’s, there is a direct mapping from a Token to a Node. However block node’s do not have a 1:1 mapping.

### Token Parsing

#### Text Token

A text token is converted directly to a `TextNode` which simply returns the text when rendered.

#### Variable Token

Variable Token’s are transformed directly to a `VariableNode`, which will evaluate a variable in the given template when rendered.

#### Comment Token

A comment token is simply omitted, a comment token will be dropped when it is converted to a Node.

#### Block Token

Block token’s are slightly different from the other tokens, there is no direct mapping. A block token is made up of a string representing the token. For example `now` or `for article in articles`. The `TokenParser` will pull out the first word inside the string representation and use that to look-up a parser for the block. So, in this example, the template tag names will be `now` or `for`.

The template tag’s are registered with a block of code which deals with the parsing for the given tag. This allows the parser to parse a set of tokens ahead of the block tone. This is useful for control flow, such as the `for` template tag will want to parse any following tokens up until the `endblock` block token.

For example:

```html+django
{% for article in articles %}
  An Article
{% endfor %}
```

Or as a set of tokens:

```swift
let tokens = [
  Token.Block("for article in articles"),
  Token.Text("  An Article")
  Token.Block("endfor")
]
```

Will result in a single Node (a `ForNode`) which contains the sub-node containing the text. The `ForNode` class has a property called `forNodes` which contains the text node representing the text token (`  An Article`).

When the `ForNode` is rendered in a context, it will look up the variable `articles` and if it’s an array it will loop over it. Inserting the variable `article` into the context while rendered the `forNodes` for each article.

### Custom Nodes

There are two ways to register custom template tags. A simple way which allows you to map 1:1 a block token to a Node. You can also register a more advanced template tag which has it’s own block of code for handling parsing if you want to parse up until another token such as if you are trying to provide flow-control.

The tags are registered with a `Namespace` passed when rendering your `Template`.

#### Simple Tags

A simple tag is registered with a string for the tag name and a block of code which is evaluated when the block is rendered in a given context.

Here’s an example. Registering a template tag called `custom` which just renders `Hello World` in the rendered template:

```swift
namespace.registerSimpleTag("custom") { context in
  return "Hello World"
}
```

You would use it as such in a template:

```html+django
{% custom %}
```

#### Advanced Tags

If you need more control or functionality than the simple tag’s above, you can use the node based API where you can provide a block of code to deal with parsing. There are a few examples of this in use over at `Node.swift` inside Stencil. There is an implementation of `if` and `for` template tags.

You would register a template tag using the `registerTag` API inside a `Namespace` which accepts a name for the tag and a block of code to handle parsing. The block of code is invoked with the parser and the current token as an argument. This allows you to use the API on `TokenParser` to parse node’s further in the token array.

As an example, we’re going to create a template tag called `debug` which will optionally render nodes from `debug` up until `enddebug`. When rendering the `DebugNode`, it will only render the nodes inside if a variable called `debug` is set to `true` inside the template Context.

```html+django
{% debug %}
  Debugging is enabled!
{% enddebug %}
```

This will be represented by a `DebugNode` which will have a property containing all of the Node’s inside the `debug`/`enddebug` block. In the above example, this will just be a TextNode containing `  Debugging is enabled!`.

When the `DebugNode` is rendered, it will determine if debug is enabled by introspecting the context and if it is enabled. We will render the nodes, otherwise just return an empty string to hide the debug output.

So, our `DebugNode` would look like as following:

```swift
class DebugNode : Node {
  let nodes:[Node]

  init(nodes:[Node]) {
    self.nodes = nodes
  }

  func render(context: Context) throws -> String {
    // Is there a debug variable inside the context?
    if let debug = context["debug"] as? Bool {
      // Is debug set to true?
      if debug {
        // Let's render the given nodes in the context since debug is enabled.
        return renderNodes(nodes, context)
      }
    }

    // Debug is turned off, so let's not render anything
    return ""
  }
}
```

We will need to write a parser to parse up until the `enddebug` template block and create a `DebugNode` with the nodes in-between. If there was another error form another Node inside, then we will return that error.

```swift
namespace.registerTag("debug") { parser, token in
  // Use the parser to parse every token up until the `enddebug` block.
  let nodes = try until(["enddebug"]))
  return DebugNode(nodes)
}
```

## Context

A Context is a structure containing any templates you would like to use in a template. It’s somewhat like a dictionary, however you can push and pop to scope variables. So that means that when iterating over a for loop, you can push a new scope into the context to store any variables local to the scope.
