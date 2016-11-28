The Stencil template language
=============================

Stencil is a simple and powerful template language for Swift. It provides a
syntax similar to Django and Mustache. If you're familiar with these, you will
feel right at home with Stencil.

.. code-block:: html+django

    There are {{ articles.count }} articles.

    <ul>
      {% for article in articles %}
        <li>{{ article.title }} by {{ article.author }}</li>
      {% endfor %}
    </ul>

.. code-block:: swift

    let context = Context(dictionary: [
      "articles": [
        [ "title": "Migrating from OCUnit to XCTest", "author": "Kyle Fuller" ],
        [ "title": "Memory Management with ARC", "author": "Kyle Fuller" ],
      ]
    ])

    do {
      let template = try Template(named: "template.stencil")
      let rendered = try template.render(context)
      print(rendered)
    } catch {
      print("Failed to render template \(error)")
    }

Contents:

.. toctree::
   :maxdepth: 2

   templates
   builtins
   custom-template-tags-and-filters
