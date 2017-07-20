import XCTest
import Vapor
import HTTP
import AuthProvider
import Authentication
import Testing

class MiddlewareTests: XCTestCase {
    override func setUp() {
        Testing.onFail = XCTFail
    }

    /// Test that an unauthenticated request to a secure
    /// page gets redirected to the login page.
    func testRedirectMiddleware() throws {
        let drop = try Droplet()

        let redirect = RedirectMiddleware.login()
        let auth = TokenAuthenticationMiddleware(TestUser.self)

        let protected = drop.grouped([redirect, auth])
        protected.get { req in
            let user = try req.auth.assertAuthenticated(TestUser.self)
            return "Welcome to the dashboard, \(user.name)"
        }

        try drop.testResponse(to: .get, at: "/")
            .assertStatus(is: .seeOther)
            .assertHeader("Location", contains: "/login")
    }

    /// Test that an authenticated request to login
    /// gets redirected to the home page.
    func testInverseRedirectMiddleware() throws {
        let drop = try Droplet()

        let redirect = InverseRedirectMiddleware.home(TestUser.self)
        let group = drop.grouped([redirect])
        group.get("login") { req in
            return "Please login"
        }

        let req = Request.makeTest(method: .get, path: "/login")
        let user = TestUser(name: "Foo")
        req.auth.authenticate(user)

        try drop.testResponse(to: req)
            .assertStatus(is: .seeOther)
            .assertHeader("Location", contains: "/")
    }

    static var allTests = [
        ("testRedirectMiddleware", testRedirectMiddleware)
    ]
}
