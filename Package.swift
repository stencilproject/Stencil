// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "Stencil",
  dependencies: [
    .package(url: "https://github.com/kylef/PathKit.git", .upToNextMinor(from: "0.9.0")),
    .package(url: "https://github.com/kylef/Spectre.git", .upToNextMinor(from: "0.8.0")),
  ]
)
