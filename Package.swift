// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "Stencil",
  products: [
    .library(name: "Stencil", targets: ["Stencil"])
  ],
  dependencies: [
    .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from: "0.9.0")),
    .package(url: "https://github.com/kylef/Spectre.git", .upToNextMinor(from: "0.8.0")),
  ],
  targets: [
    .target(
      name: "Stencil",
      dependencies: ["PathKit","Spectre"]
    ),
    .testTarget(
      name: "StencilTests",
      dependependencies: ["Stencil"]
    )
  ]
)
