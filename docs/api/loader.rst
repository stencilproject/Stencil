Loader
======

Loaders are responsible for loading templates from a resource such as the file
system.

Stencil provides a ``FileSytemLoader`` which allows you to load a template
directly from the file system.

``Loader`` is a protocol, so you can implement your own compatible loaders. You
will need to implement a ``loadTemplate`` method to load the template,
throwing a ``TemplateDoesNotExist`` when the template is not found.

.. code-block:: swift

    class ExampleMemoryLoader: Loader {
      func loadTemplate(name: String, environment: Environment) throws -> Template {
        if name == "index.html" {
          return Template(templateString: "Hello", environment: environment)
        }

        throw TemplateDoesNotExist()
      }
    }

FileSystemLoader
----------------

Loads templates from the file system. This loader can find templates in folders
on the file system.

.. code-block:: swift

    FileSystemLoader(paths: ["./templates"])

.. code-block:: swift

    FileSystemLoader(bundle: [Bundle.main])
