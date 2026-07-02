// swift-tools-version:6.0

import PackageDescription

let package = Package(
    name: "SUIAppNavigationRouter",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "SUIAppNavigationRouter",
            targets: ["SUIAppNavigationRouter"]
        ),
    ],
    targets: [
        .target(
            name: "SUIAppNavigationRouter",
            dependencies: []
        ),
    ]
)
