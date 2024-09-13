// swift-tools-version: 5.10

import PackageDescription

let package = Package(
  name: "swift-recipes-app",
  platforms: [
    .iOS(.v17),
    .visionOS(.v1)
  ],
  products: [
    // Dependencies
    .library(name: "ApiClient"),

    // Features
    .library(name: "AppReducer"),
    .library(name: "MealDetails"),
    .library(name: "MealList"),

    // Libraries
    .library(name: "SharedState"),
    .library(name: "SharedModels"),
    .library(name: "DesignSystem"),
    .library(name: "AsyncHelpers"),
    .library(name: "FoundationExtensions"),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "1.15.0"),
    .package(url: "https://github.com/pointfreeco/swift-tagged", from: "0.6.0"),
    .package(url: "https://github.com/tgrapperon/swift-dependencies-additions", from: "1.0.2"),
    .package(url: "https://github.com/groue/GRDB.swift", from: "6.27.0"),
    .package(url: "https://github.com/gohanlon/swift-memberwise-init-macro", branch: "main"),
  ],
  targets: [
    // Dependencies
    .dependency("ApiClient"),

    // Features
    .feature("AppReducer", dependencies: [
      "ApiClient",
      "MealList"
    ]),
    .feature("MealList", dependencies: [
      "ApiClient",
      "MealDetails"
    ]),
    .feature("MealDetails", dependencies: [
      "ApiClient",
    ]),

    // Libraries
    .library("SharedState", dependencies: [
      "ApiClient",
      "SharedModels",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      .product(name: "Tagged", package: "swift-tagged"),
    ]),
    .library("SharedModels", dependencies: [
      "ApiClient",
      .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      .product(name: "Tagged", package: "swift-tagged"),
    ]),
    .library("DesignSystem", resources: [.process("Fonts")]),
    .library("AsyncHelpers"),
    .library("FoundationExtensions"),
    .library("SwiftUIHelpers"),
  ]
)

// MARK: - Helpers

extension Product {

  /// Create a library with identical name & target.
  static func library(name: String) -> Product {
    .library(name: name, targets: [name])
  }
}

extension Target {

  /// Create a target with the default path & dependencies for a feature.
  static func feature(_ name: String, dependencies: [Target.Dependency] = []) -> Target {
    .target(
      name: name,
      dependencies: dependencies + [
        "SharedState",
        "DesignSystem",
        "SwiftUIHelpers",
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Tagged", package: "swift-tagged"),
      ],
      path: "Sources/Features/\(name)"
    )
  }

  /// Create a target with the default path & dependencies for a dependency.
  static func dependency(_ name: String, dependencies: [Target.Dependency] = []) -> Target {
    .target(
      name: name,
      dependencies: dependencies + [
        .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
        .product(name: "Tagged", package: "swift-tagged"),
        .product(name: "MemberwiseInit", package: "swift-memberwise-init-macro"),
      ],
      path: "Sources/DependencyClients/\(name)"
    )
  }

  /// Create a target with the default path & dependencies for a library.
  static func library(
    _ name: String,
    dependencies: [Target.Dependency] = [],
    resources: [Resource] = []
  ) -> Target {
    .target(
      name: name,
      dependencies: dependencies,
      path: "Sources/Library/\(name)",
      resources: resources
    )
  }
}
