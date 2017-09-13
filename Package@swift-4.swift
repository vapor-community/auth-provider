// swift-tools-version:4.0
import PackageDescription

let package = Package(
    name: "AuthProvider",
    products: [
    	.library(name: "AuthProvider", targets: ["AuthProvider"]),
    ],
    dependencies: [
        // A web framework and server for Swift that works on macOS and Ubuntu. 
        .package(url: "https://github.com/vapor/auth.git", .upToNextMajor(from: "1.2.0")),

        // A web framework and server for Swift that works on macOS and Ubuntu. 
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.2.0")),
    ],
    targets: [
    	.target(name: "AuthProvider", dependencies: ["Authentication", "Authorization", "Vapor"]),
    	.testTarget(name: "AuthProviderTests", dependencies: ["AuthProvider", "Testing"])
    ]
)
