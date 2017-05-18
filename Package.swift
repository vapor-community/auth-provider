import PackageDescription

let package = Package(
    name: "AuthProvider",
    dependencies: [
        // A web framework and server for Swift that works on macOS and Ubuntu. 
        .Package(url: "https://github.com/vapor/auth.git", majorVersion: 1),

        // A web framework and server for Swift that works on macOS and Ubuntu. 
        .Package(url: "https://github.com/vapor/vapor.git", majorVersion: 2),
    ]
)
