import Fluent
import AuthProvider
import HTTP

final class TestUser: Entity {
    let name: String
    let storage = Storage()

    var tokens: Children<TestUser, TestToken> {
        return children()
    }
    
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

extension TestUser: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

// MARK: Authentication

extension TestUser: TokenAuthenticatable {
    // join the TestToken table and search for
    // the supplied bearer token to authenticate
    // the user
    public typealias TokenType = TestToken
}

// MARK: HTTP

extension Request {
    func user() throws -> TestUser {
        return try auth.assertAuthenticated()
    }
}

// MARK: Sessions

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
