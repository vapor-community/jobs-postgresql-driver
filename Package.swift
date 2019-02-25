// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "JobsPostgreSQLDriver",
    products: [
        .library(
            name: "JobsPostgreSQLDriver",
            targets: ["JobsPostgreSQLDriver"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor-community/jobs.git", from: "0.2.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "JobsPostgreSQLDriver",
            dependencies: ["Jobs", "FluentPostgreSQL"]),
        .testTarget(
            name: "JobsPostgreSQLDriverTests",
            dependencies: ["JobsPostgreSQLDriver"]),
    ]
)
