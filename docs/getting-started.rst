Getting Started
===============

The easiest way to render a template using Stencil is to create a template and
call render on it providing a context.

.. code-block:: swift

    let template = Template(templateString: "Hello {{ name }}")
    try template.render(["name": "kyle"])

For more advanced uses, you would normally create an ``Environment`` and call
the ``renderTemplate`` convinience method.

.. code-block:: swift

    let environment = Environment()

    let context = ["name": "kyle"]
    try template.renderTemplate(string: "Hello {{ name }}", context: context)

Template Loaders
----------------

A template loader allows you to load files from disk or elsewhere. Using a
``FileSystemLoader`` we can easily render a template from disk.

For example, to render a template called ``index.html`` inside the
``templates/`` directory we can use the following:

.. code-block:: swift

    let fsLoader = FileSystemLoader(paths: ["templates/"])
    let environment = Environment(loader: fsLoader)

    let context = ["name": "kyle"]
    try template.renderTemplate(name: "index.html", context: context)
