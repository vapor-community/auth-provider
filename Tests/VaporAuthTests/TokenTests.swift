import XCTest
import Vapor
import HTTP
@testable import VaporAuth

class TokenTests: XCTestCase {
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

extension TestUser: TokenAuthenticatable {
    // This is the only conformance needed to make
    // TestUser authenticatable with tokens!
    public typealias TokenType = TestUser

    // but we're going to do a custom method instead
    public static func authenticate(_ token: Token) throws -> Self {
        return self.init(name: token.string)
    }
}

extension Request {
    func user() throws -> TestUser {
        return try auth.authenticated()
    }
}

extension TokenTests {
    // Test stateless token authentication
    func testAuthentication() throws {
        let drop = try Droplet()

        drop.middleware += TokenAuthenticationMiddleware(TestUser.self)

        drop.get("name") { req in
            // return the users name
            return try req.user().name
        }

        let token = "foo"

        let req = Request(.get, "name")
        req.headers["Authorization"] = "Bearer \(token)"
        let res = drop.respond(to: req)

        XCTAssertEqual(res.body.bytes?.string, token)
    }
}

// MARK: Sessions

// Session based token authentication
//
// `Authorization: Bearer <token here>` header must only be passed once
// After that, the cookie can act as a login persister

import Sessions

extension TestUser: SessionPersistable {
    public static func fetchPersisted(for req: Request) throws -> Self? {
        // take the cookie and set it as the user's
        // name for easy verification
        guard let cookie = req.cookies["vapor-session"] else {
            return nil
        }
        return self.init(name: cookie)
    }
}

extension TokenTests {

    func testPersistance() throws {
        let drop = try Droplet()

        let sessions = MemorySessions()
        drop.middleware += SessionsMiddleware(sessions)
        drop.middleware += PersistMiddleware(TestUser.self)
        drop.middleware += TokenLoginMiddleware(TestUser.self)

        // add the token middleware to a route group
        drop.get("name") { req in
            // return the users name
            return try req.user().name
        }

        let token = "foo"

        // login request with token
        let req = Request(.get, "name")
        req.headers["Authorization"] = "Bearer \(token)"
        let res = drop.respond(to: req)

        // verify response and get cookie
        XCTAssertEqual(res.body.bytes?.string, token)
        guard let cookie = res.cookies["vapor-session"] else {
            XCTFail("No cookie")
            return
        }

        // logged in request with cookie
        let req2 = Request(.get, "name")
        req2.cookies["vapor-session"] = cookie
        let res2 = drop.respond(to: req2)

        XCTAssertEqual(res2.body.bytes?.string, cookie)
    }
}

