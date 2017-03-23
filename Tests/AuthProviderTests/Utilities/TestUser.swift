import Fluent

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
            users.id(for: self)
            users.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}
