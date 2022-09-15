// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "SwiftyAlert",
  platforms: [
    .iOS(.v13),
    .tvOS(.v13)
  ],
  products: [
    .library(
      name: "SwiftyAlert",
      targets: ["SwiftyAlert"]
    )
  ],
  targets: [
    .target(
      name: "SwiftyAlert",
      dependencies: []
    ),
    .testTarget(
      name: "SwiftyAlertTests",
      dependencies: ["SwiftyAlert"]
    )
  ]
)
