import PackageDescription

let package = Package(
  name: "Stencil",
  dependencies: [
    .Package(url: "https://github.com/huawei-brice/PathKit.git", majorVersion: 0, minor: 6),
  ]
)
