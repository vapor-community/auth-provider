import PackageDescription

let package = Package(
    name: "AuthProvider",
    dependencies: [
        // A web framework and server for Swift that works on macOS and Ubuntu. 
        .Package(url: "https://github.com/vapor/auth.git", Version(1,0,0, prereleaseIdentifiers: ["beta"])),

        // A web framework and server for Swift that works on macOS and Ubuntu. 
        .Package(url: "https://github.com/vapor/vapor.git", Version(2,0,0, prereleaseIdentifiers: ["beta"]))
    ]
)
