// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "swift-loader-primitives",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
        .visionOS(.v26),
    ],
    products: [
        .library(
            name: "Loader Primitives",
            targets: ["Loader_Primitives"]
        ),
    ],
    dependencies: [
        .package(path: "../swift-string-primitives"),
        .package(path: "../swift-reference-primitives"),
        .package(path: "../swift-ascii-primitives"),
    ],
    targets: [
        .target(
            name: "Loader_Primitives",
            dependencies: [
                .product(name: "String Primitives", package: "swift-string-primitives"),
                .product(name: "Reference Primitives", package: "swift-reference-primitives"),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
            ],
            path: "Sources/Loader Primitives"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let settings: [SwiftSetting] = [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableExperimentalFeature("Lifetimes"),
        .strictMemorySafety(),
    ]
    target.swiftSettings = (target.swiftSettings ?? []) + settings
}
