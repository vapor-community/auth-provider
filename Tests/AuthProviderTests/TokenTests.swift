import XCTest
import Vapor
import HTTP
@testable import AuthProvider
import Authentication

class TokenTests: XCTestCase {
    
    override func setUp() {
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
        let drop = try Droplet()

        let tokenMiddleware = TokenAuthenticationMiddleware(TestUser.self)
        drop.middleware.append(tokenMiddleware)

        drop.get("name") { req in
            // return the users name
            return try req.user().name
        }

        let req = Request(.get, "name")
        req.headers["Authorization"] = "Bearer foo"
        let res = drop.respond(to: req)

        XCTAssertEqual(res.body.bytes?.makeString(), "Bob")
    }
}

// MARK: Sessions

// Session based token authentication
//
// `Authorization: Bearer <token here>` header must only be passed once
// After that, the cookie can act as a login persister

import Sessions

extension TokenTests {

    func testPersistance() throws {
        let drop = try Droplet()

        let sessions = MemorySessions()
        drop.middleware.append(SessionsMiddleware(sessions))
        drop.middleware.append(PersistMiddleware(TestUser.self))
        drop.middleware.append(TokenLoginMiddleware(TestUser.self))

        // add the token middleware to a route group
        drop.get("name") { req in
            // return the users name
            return try req.user().name
        }

        // login request with token
        let req = Request(.get, "name")
        req.headers["Authorization"] = "Bearer foo"
        let res = drop.respond(to: req)

        // verify response and get cookie
        XCTAssertEqual(res.body.bytes?.makeString(), "Bob")
        guard let cookie = res.cookies["vapor-session"] else {
            XCTFail("No cookie")
            return
        }

        // logged in request with cookie
        let req2 = Request(.get, "name")
        req2.cookies["vapor-session"] = cookie
        let res2 = drop.respond(to: req2)

        XCTAssertEqual(res2.body.bytes?.makeString(), cookie)
    }
}

