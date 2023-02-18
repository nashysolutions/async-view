// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "async-view",
    platforms: [.iOS(.v14), .macOS(.v11), .tvOS(.v14), .watchOS(.v7)],
    products: [
        .library(
            name: "AsyncView",
            targets: ["AsyncView"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/nashysolutions/Cache.git", .upToNextMinor(from: "3.0.0")),
        .package(url: "https://github.com/pointfreeco/swift-dependencies.git", .upToNextMinor(from: "0.1.4"))
    ],
    targets: [
        .target(
            name: "AsyncView",
            dependencies: [
                "Cache",
                .product(name: "Dependencies", package: "swift-dependencies")
            ]
        ),
        .testTarget(
            name: "AsyncViewTests",
            dependencies: [
                "AsyncView",
                "Cache",
                .product(name: "Dependencies", package: "swift-dependencies")
            ],
            resources: [.process("Resources")]
        )
    ]
)
