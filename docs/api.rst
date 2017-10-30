Template API
============

This document describes Stencils Swift API, and not the Swift template language.

.. contents:: :depth: 2

Environment
-----------

An environment contains shared configuration such as custom filters and tags
along with template loaders.

.. code-block:: swift

    let environment = Environment()

You can optionally provide a loader or extensions when creating an environment:

.. code-block:: swift

    let environment = Environment(loader: ..., extensions: [...])

Rendering a Template
~~~~~~~~~~~~~~~~~~~~

Environment provides convinience methods to render a template either from a
string or a template loader.

.. code-block:: swift

    let template = "Hello {{ name }}"
    let context = ["name": "Kyle"]
    let rendered = environment.renderTemplate(string: template, context: context)

Rendering a template from the configured loader:

.. code-block:: swift

    let context = ["name": "Kyle"]
    let rendered = environment.renderTemplate(name: "example.html", context: context)

Loading a Template
~~~~~~~~~~~~~~~~~~

Environment provides an API to load a template from the configured loader.

.. code-block:: swift

    let template = try environment.loadTemplate(name: "example.html")

Loader
------

Loaders are responsible for loading templates from a resource such as the file
system.

Stencil provides a ``FileSytemLoader`` which allows you to load a template
directly from the file system.

FileSystemLoader
~~~~~~~~~~~~~~~~

Loads templates from the file system. This loader can find templates in folders
on the file system.

.. code-block:: swift

    FileSystemLoader(paths: ["./templates"])

.. code-block:: swift

    FileSystemLoader(bundle: [Bundle.main])


DictionaryLoader
~~~~~~~~~~~~~~~~

Loads templates from a dictionary.

.. code-block:: swift

    DictionaryLoader(templates: ["index.html": "Hello World"])


Custom Loaders
~~~~~~~~~~~~~~

``Loader`` is a protocol, so you can implement your own compatible loaders. You
will need to implement a ``loadTemplate`` method to load the template,
throwing a ``TemplateDoesNotExist`` when the template is not found.

.. code-block:: swift

    class ExampleMemoryLoader: Loader {
      func loadTemplate(name: String, environment: Environment) throws -> Template {
        if name == "index.html" {
          return Template(templateString: "Hello", environment: environment)
        }

        throw TemplateDoesNotExist(name: name, loader: self)
      }
    }


Context
-------

A ``Context`` is a structure containing any templates you would like to use in
a template. It’s somewhat like a dictionary, however you can push and pop to
scope variables. So that means that when iterating over a for loop, you can
push a new scope into the context to store any variables local to the scope.

You would normally only access the ``Context`` within a custom template tag or
filter.

Subscripting
~~~~~~~~~~~~

You can use subscripting to get and set values from the context.

.. code-block:: swift

    context["key"] = value
    let value = context["key"]

``push()``
~~~~~~~~~~

A ``Context`` is a stack. You can push a new level onto the ``Context`` so that
modifications can easily be poped off. This is useful for isolating mutations
into scope of a template tag. Such as ``{% if %}`` and ``{% for %}`` tags.

.. code-block:: swift

    context.push(["name": "example"]) {
        // context contains name which is `example`.
    }

    // name is popped off the context after the duration of the closure.

``flatten()``
~~~~~~~~~~~~~

Using ``flatten()`` method you can get whole ``Context`` stack as one
dictionary including all variables.

.. code-block:: swift

    let dictionary = context.flatten()
