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
        .Package(url: "https://github.com/kylef/Stencil.git", majorVersion: 0, minor: 7),
      ]
    )

CocoaPods
---------

If you're using CocoaPods, you can add Stencil to your ``Podfile`` and then run
``pod install``.

.. code-block:: ruby

    pod 'Stencil'
