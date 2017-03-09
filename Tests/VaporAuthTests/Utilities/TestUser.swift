import Fluent

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


import HTTP
import URI

extension Request {
    convenience init(_ method: Method, _ path: String) {
        let uri = URI(host: "0.0.0.0", path: path)
        self.init(method: method, uri: uri)
    }
}
