// swift-tools-version: 6.0.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let packageName = "SwiftCore"
let generatedName = "Generated"
let generatedPath = ".build/\(generatedName.lowercased())"

func getAndroidLibTarget() -> Target {
    Target.target(
        name: generatedName,
        dependencies: [
            .byName(name: packageName),
            .product(name: "Java", package: "swift-java"),
            .product(name: "java_swift", package: "java_swift"),
            .product(name: "JavaCoder", package: "swift-java-coder"),
            .product(name: "AndroidNDK", package: "swift-android-ndk")
        ],
        path: generatedPath,
        linkerSettings: [
            .unsafeFlags(["-Xlinker", "-soname", "-Xlinker", "lib\(packageName).so"])
        ]
    )
}

let package = Package(
    name: packageName,
    // Products define the executables and libraries a package produces, making them visible to other packages.
    products: [
        .library(name: packageName, type: .dynamic, targets: [generatedName])
    ],

    dependencies: [
        .package(url: "https://github.com/readdle/java_swift.git", exact: "2.2.3"),
        .package(url: "https://github.com/readdle/swift-java.git", exact: "0.3.0"),
        .package(url: "https://github.com/readdle/swift-java-coder.git", exact: "1.1.2"),
        .package(url: "https://github.com/readdle/swift-android-ndk.git", exact: "1.1.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: packageName,
            dependencies: [
                .product(name: "Java", package: "swift-java"),
                .product(name: "java_swift", package: "java_swift"),
                .product(name: "JavaCoder", package: "swift-java-coder"),
                .product(name: "AndroidNDK", package: "swift-android-ndk")
            ],
            // Non-default path so we need to specify it. Otherwise, it will be `Sources/<target-name>`.
            path: "Sources"),
        getAndroidLibTarget()
    ],
    swiftLanguageVersions: [.v5]
)
