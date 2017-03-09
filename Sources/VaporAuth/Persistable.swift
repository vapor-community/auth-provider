import HTTP

public protocol Persistable {
    func persist(for: Request) throws
    static func fetchPersisted(for: Request) throws -> Self?
}

import Authentication

public final class PersistMiddleware<U: Authenticatable & Persistable>: Middleware {
    public init(_ userType: U.Type = U.self) {}

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let user = try U.fetchPersisted(for: request) {
            request.auth.authenticate(user)
        }

        return try next.respond(to: request)
    }
}


// MARK: Session

import Sessions
import Fluent

public protocol SessionPersistable: Persistable, Entity {}

extension SessionPersistable {
    public func persist(for request: Request) throws {
        try request.session().data.set("session-id", id)
    }

    public static func fetchPersisted(for request: Request) throws -> Self? {
        guard let id = try request.session().data["session-id"] else {
            return nil
        }

        guard let user = try Self.find(id) else {
            return nil
        }

        return user
    }
}
