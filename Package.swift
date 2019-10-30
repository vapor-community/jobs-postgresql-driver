// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "JobsPostgreSQLDriver",
    products: [
        .library(
            name: "JobsPostgreSQLDriver",
            targets: ["JobsPostgreSQLDriver"]
        ),
    ],
    dependencies: [
        .package(
            url: "https://github.com/vapor/vapor.git",
            from: "3.0.0"
        ),
        .package(
            url: "https://github.com/tonyarnold/jobs.git",
            .branch("feature/backport-delay-until-to-3")
        ),
        .package(
            url: "https://github.com/vapor/fluent-postgres-driver.git",
            from: "1.0.0"
        ),
    ],
    targets: [
        .target(
            name: "JobsPostgreSQLDriver",
            dependencies: [
                "Jobs",
                "FluentPostgreSQL",
                "Vapor"
            ]
        ),
        .testTarget(
            name: "JobsPostgreSQLDriverTests",
            dependencies: [
                "JobsPostgreSQLDriver"
            ]
        ),
    ]
)
