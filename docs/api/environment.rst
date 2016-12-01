Environment
===========

An environment contains shared configuration such as custom filters and tags
along with template loaders.

.. code-block:: swift

    let environment = Environment()

You can optionally provide a loader or namespace when creating an environment:

.. code-block:: swift

    let environment = Environment(loader: ..., namespace: ...)

Rendering a Template
--------------------

Environment providences coninience methods to render a template either from a
string or a template loader.

.. code-block:: swift

    let template = "Hello {{ name }}"
    let context = ["name": "Kyle"]
    let rendered = environment.render(templateString: template, context: context)

Rendering a template from the configured loader:

.. code-block:: swift

    let context = ["name": "Kyle"]
    let rendered = environment.render(templateName: "example.html", context: context)

Loading a Template
------------------

Environment provides an API to load a template from the configured loader.

.. code-block:: swift

    let template = try environment.loadTemplate(name: "example.html")
