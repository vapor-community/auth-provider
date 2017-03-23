# Auth Provider

![Swift](http://img.shields.io/badge/swift-3.1-brightgreen.svg)
[![CircleCI](https://circleci.com/gh/vapor/auth-provider.svg?style=shield)](https://circleci.com/gh/vapor/auth-provider)
[![Slack Status](http://vapor.team/badge.svg)](http://vapor.team)

Integrations the [Auth](https://github.com/vapor/auth) package with the [Vapor](https://github.com/vapor/vapor) web framework.

- [x] Token Authentication
- [x] Username/Password Authentication
- [x] Permission based Authorization

## Basic Token Auth

Here is an example of basic `Authorization: Bearer` authentication using the Auth provider.

### User model

A basic example user:

```swift
final class TestUser: Entity {
    let name: String
    let storage = Storage()

    init(name: String) {
        self.name = name
    }

    init(row: Row) throws {
        name = try row.get("name")
    }

    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
}

```

### Authenticatable

Start by conforming a model to the `TokenAuthenticatable` protocol.

```swift
extension TestUser: TokenAuthenticatable {
    // set `TokenType` to self since we are doing
    // a custom implementation of `authenticate(...)`
    public typealias TokenType = TestUser

    // assert the token supplied is equal to "foo"
    // and return a user named Bob
    public static func authenticate(_ token: Token) throws -> Self {
        guard token.string == "foo" else {
            throw AuthenticationError.invalidCredentials
        }
        
        return self.init(name: "Bob")
    }
}
```

Add an optional convenience to get the `TestUser`.

```
extension Request {
    func user() throws -> TestUser {
        return try auth.assertAuthenticated()
    }
}
```

### Droplet

Setup the Droplet.

```swift
let drop = try Droplet()

let tokenMiddleware = TokenAuthenticationMiddleware(TestUser.self)
drop.middleware.append(tokenMiddleware)

drop.get("name") { req in
    // return the users name
    return try req.user().name
}

try drop.start()
```

An example request would look like:

```swift
let token = "foo"

let req = Request(.get, "name")
req.headers["Authorization"] = "Bearer \(token)"

let res = drop.respond(to: req)
print(res) // body will contain "Bob"
```

## 📖 Documentation

Visit the Vapor web framework's [documentation](http://docs.vapor.codes) for instructions on how to use this package. 

## 💧 Community

Join the welcoming community of fellow Vapor developers in [slack](http://vapor.team).

## 🔧 Compatibility

This package has been tested on macOS and Ubuntu.
