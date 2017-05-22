import XCTest
import Vapor
import HTTP
@testable import AuthProvider
import Authentication

class TokenTests: XCTestCase {
    
    override func setUp() {
        Node.fuzzy = [Node.self]
        
        let memory = try! MemoryDriver()
        let database = Database(memory)
        
        database.log = { query in
            print(query)
        }
        
        TestToken.database = database
        TestUser.database = database
        
        try! TestToken.prepare(database)
        try! TestUser.prepare(database)
        
        // add user and token to db
        let user = TestUser(name: "Bob")
        try! user.save()
        let token = try! TestToken(token: "foo", user)
        try! token.save()
    }
    
    static var allTests = [
        ("testAuthentication", testAuthentication),
        ("testPersistance", testPersistance)
    ]
}

// MARK: Stateless

import Authentication
import Fluent

// Tests stateless token authentication
//
// `Authorization: Bearer <token here>` header must be passed
// with every request

extension TokenTests {
    // Test stateless token authentication
    func testAuthentication() throws {
        var config = Config([:])
        try config.set("droplet.middleware", [
            "token"
        ])
        
        config.addConfigurable(middleware: { config in
            TokenAuthenticationMiddleware(TestUser.self)
        }, name: "token")
        
        let drop = try Droplet(config)

        drop.get("name") { req in
            // return the users name
            return try req.user().name
        }

        let req = Request(.get, "name")
        req.headers["Authorization"] = "Bearer foo"
        let res = try drop.respond(to: req)

        XCTAssertEqual(res.body.bytes?.makeString(), "Bob")
    }
}

// MARK: Sessions

// Session based token authentication
//
// `Authorization: Bearer <token here>` header must only be passed once
// After that, the cookie can act as a login persister

import Sessions
import Cookies

extension TokenTests {

    func testPersistance() throws {
        var config = Config([:])
        try config.set("droplet.middleware", [
            "sessions",
            "persist",
            "token"
        ])
        
        config.addConfigurable(middleware: { config in
            return PersistMiddleware(TestUser.self)
        }, name: "persist")
        
        config.addConfigurable(middleware: { config in
            return TokenAuthenticationMiddleware(TestUser.self)
        }, name: "token")
        
        let drop = try Droplet(config)


        // add the token middleware to a route group
        drop.get("name") { req in
            // return the users name
            return try req.user().name
        }

        // login request with token
        let req = Request(.get, "name")
        req.headers["Authorization"] = "Bearer foo"
        let res = try drop.respond(to: req)

        // verify response and get cookie
        XCTAssertEqual(res.body.bytes?.makeString(), "Bob")
        guard let cookie = res.cookies["vapor-session"] else {
            XCTFail("No cookie")
            return
        }

        // logged in request with cookie
        let req2 = Request(.get, "name")
        req2.cookies["vapor-session"] = cookie
        let res2 = try drop.respond(to: req2)
        XCTAssertEqual(res2.cookies.array.count, 0)

        XCTAssertEqual(res2.body.bytes?.makeString(), "Bob")
    }
}

