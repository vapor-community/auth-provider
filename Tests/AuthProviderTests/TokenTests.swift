import XCTest
import Vapor
import HTTP
@testable import AuthProvider
import Authentication

class TokenTests: XCTestCase {
    
    override func setUp() {
        let memory = try! SQLiteDriver(path: ":memory:")
        let database = Database(memory)
        
        database.log = { query in
            print(query)
        }
        
        TestToken.database = database
        TestUser.database = database
        
        try! TestToken.prepare(database)
        try! TestUser.prepare(database)
        
        // add user and token to db
        let tokenString = "foo"
        let user = TestUser(name: "Bob")
        try! user.save()
        let token = try! TestToken(token: tokenString, user)
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

extension TestUser: TokenAuthenticatable {
    // join the TestToken table and search for
    // the supplied bearer token to authenticate
    // the user
    public typealias TokenType = TestToken
}

extension Request {
    func user() throws -> TestUser {
        return try auth.assertAuthenticated()
    }
}

extension TokenTests {
    // Test stateless token authentication
    func testAuthentication() throws {
        do {
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
        } catch {
            XCTFail("\(error)")
        }
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

