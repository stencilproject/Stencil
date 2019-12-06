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

    import Stencil

    struct Article {
      let title: String
      let author: String
    }

    let context = [
      "articles": [
        Article(title: "Migrating from OCUnit to XCTest", author: "Kyle Fuller"),
        Article(title: "Memory Management with ARC", author: "Kyle Fuller"),
      ]
    ]

    let environment = Environment(loader: FileSystemLoader(paths: ["templates/"])
    let rendered = try environment.renderTemplate(name: "articles.html", context: context)

    print(rendered)

The User Guide
--------------

For Template Writers
~~~~~~~~~~~~~~~~~~~~

Resources for Stencil template authors to write Stencil templates.

.. toctree::
   :maxdepth: 2

   templates
   builtins

For Developers
~~~~~~~~~~~~~~

Resources to help you integrate Stencil into a Swift project.

.. toctree::
   :maxdepth: 1

   installation
   getting-started
   api
   custom-template-tags-and-filters
