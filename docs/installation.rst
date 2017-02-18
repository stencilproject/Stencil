Installation
============

Swift Package Mangaer
---------------------

If you're using the Swift Package Manager, you can add ``Stencil`` to your
dependencies inside ``Package.swift``.

.. code-block:: swift

    import PackageDescription

    let package = Package(
      name: "MyApplication",
      dependencies: [
        .Package(url: "https://github.com/kylef/Stencil.git", majorVersion: 0, minor: 8),
      ]
    )

CocoaPods
---------

If you're using CocoaPods, you can add Stencil to your ``Podfile`` and then run
``pod install``.

.. code-block:: ruby

    pod 'Stencil', '~> 0.8.0'

Carthage
--------

.. note:: Use at your own risk. We don't offer support for Carthage and instead recommend you use Swift Package Manager.

1) Add ``Stencil`` to your ``Cartfile``:

    .. code-block:: text

        github "kylef/Stencil" ~> 0.8.0

2) Checkout your dependencies, generate the Stencil Xcode project, and then use Carthage to build Stencil:

    .. code-block:: shell

        $ carthage update
        $ (cd Carthage/Checkouts/Stencil && swift package generate-xcodeproj)
        $ carthage build

3) Follow the Carthage steps to add the built frameworks to your project.

To learn more about this approach see `Using Swift Package Manager with Carthage <https://fuller.li/posts/using-swift-package-manager-with-carthage/>`_.
