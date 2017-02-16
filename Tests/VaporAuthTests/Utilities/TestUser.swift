import Fluent

final class TestUser: Entity {
    var id: Node?
    let name: String

    init(name: String) {
        self.name = name
    }

    init(node: Node, in context: Context) throws {
        id = try node.extract(TestUser.idKey)
        name = try node.extract("name")
    }

    func makeNode(context: Context) throws -> Node {
        return try Node(node: [
            TestUser.idKey: id,
            "name": name
        ])
    }

    static func prepare(_ database: Database) throws {
        try database.create(entity) { users in
            users.id(for: self)
            users.string("name")
        }
    }

    static func revert(_ database: Database) throws {
        try database.delete(entity)
    }
}


import HTTP
import URI

extension Request {
    convenience init(_ method: Method, _ path: String) throws {
        let uri = URI(host: "0.0.0.0", path: path)
        try self.init(method: method, uri: uri)
    }
}
