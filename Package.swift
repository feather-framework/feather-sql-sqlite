// swift-tools-version:6.3
import PackageDescription

let swiftSettings: [SwiftSetting] = [
    .swiftLanguageMode(.v6),
    .strictMemorySafety(),
    .treatAllWarnings(as: .error),
    .enableUpcomingFeature("InternalImportsByDefault"),
    .enableUpcomingFeature("ExistentialAny"),
    .enableUpcomingFeature("MemberImportVisibility"),
    .enableUpcomingFeature("InferIsolatedConformances"),
    .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
    .enableUpcomingFeature("ImmutableWeakCaptures"),
    .enableUpcomingFeature("StrictConcurrency"),
    .enableExperimentalFeature("SuppressedAssociatedTypes"),
    .enableExperimentalFeature("LifetimeDependence"),
    .enableExperimentalFeature("Lifetimes"),
]

let package = Package(
    name: "feather-sql-sqlite",
    platforms: [
        .macOS(.v15),
        .iOS(.v18),
        .tvOS(.v18),
        .watchOS(.v11),
        .visionOS(.v2),
    ],
    products: [
        .library(name: "FeatherSQLSQLite", targets: ["FeatherSQLSQLite"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/feather-framework/feather-sql",
            exact: "1.0.0-alpha.1"
        ),
    ],
    targets: [
        .target(
            name: "FeatherSQLSQLite",
            dependencies: [
                .product(name: "FeatherSQL", package: "feather-sql"),
            ],
            swiftSettings: swiftSettings
        ),
        .testTarget(
            name: "FeatherSQLSQLiteTests",
            dependencies: ["FeatherSQLSQLite", .product(name: "FeatherSQL", package: "feather-sql")],
            swiftSettings: swiftSettings
        ),
    ]
)
