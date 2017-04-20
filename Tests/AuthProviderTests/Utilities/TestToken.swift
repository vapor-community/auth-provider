import Fluent

final class TestToken: Entity {
    let token: String
    let userId: Identifier
    let storage = Storage()
    
    var user: Parent<TestToken, TestUser> {
        return parent(id: userId)
    }
    
    init(token: String, _ user: TestUser) throws {
        self.token = token
        self.userId = try user.assertExists()
    }
    
    init(row: Row) throws {
        token = try row.get("token")
        userId = try row.get(TestUser.foreignIdKey)
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("token", token)
        try row.set(TestUser.foreignIdKey, userId)
        return row
    }
}


extension TestToken: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { users in
            users.id()
            users.string("token")
            users.foreignId(for: TestUser.self)
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
