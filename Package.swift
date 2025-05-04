// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "BooksDiscordRichPresence",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "BooksDiscordRichPresence", targets: ["BooksDiscordRichPresence"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.15.3")
    ],
    targets: [
        .executableTarget(
            name: "BooksDiscordRichPresence",
            dependencies: [
                .product(name: "SQLite", package: "SQLite.swift")
            ],
            path: "Sources/BooksDiscordRichPresence",
        )
    ]
)

