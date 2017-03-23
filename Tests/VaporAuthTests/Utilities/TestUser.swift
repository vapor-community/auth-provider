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
}


import HTTP
import URI

extension Request {
    convenience init(_ method: Method, _ path: String) {
        let uri = URI(hostname: "0.0.0.0", path: path)
        self.init(method: method, uri: uri)
    }
}
