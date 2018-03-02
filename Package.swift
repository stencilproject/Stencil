// swift-tools-version:4.0
import PackageDescription

let package = Package(
  name: "Stencil",
  dependencies: [
    .Package(url: "https://github.com/kylef/PathKit.git", majorVersion: 0, minor: 9),
    .Package(url: "https://github.com/kylef/Spectre.git", majorVersion: 0, minor: 8),
  ]
)
