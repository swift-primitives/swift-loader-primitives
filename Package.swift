// swift-tools-version: 6.3

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
        .package(path: "../swift-ownership-primitives"),
        .package(path: "../swift-ascii-primitives"),
        // SDG(wraps): loader errors wrap platform error codes (errno/GetLastError)
        // .package(path: "../swift-error-primitives"),
        // SDG(wraps): library handles wrap scoped lifetimes
        // .package(path: "../swift-lifetime-primitives"),
    ],
    targets: [
        .target(
            name: "Loader_Primitives",
            dependencies: [
                .product(name: "String Primitives", package: "swift-string-primitives"),
                .product(name: "Ownership Primitives", package: "swift-ownership-primitives"),
                .product(name: "ASCII Primitives", package: "swift-ascii-primitives"),
                // .product(name: "Error Primitives", package: "swift-error-primitives"),
                // .product(name: "Lifetime Primitives", package: "swift-lifetime-primitives"),
            ],
            path: "Sources/Loader Primitives"
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("LifetimeDependence"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
        .enableUpcomingFeature("InferIsolatedConformances"),
        .enableUpcomingFeature("LifetimeDependence"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
