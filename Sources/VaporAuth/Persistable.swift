import HTTP
import Authentication

/// Models conforming to this protocol
/// can be persisted using `PersistMiddleware`
/// and the `req.auth.authenticate(..., persist: true)` method.
public protocol Persistable {
    func persist(for: Request) throws
    static func fetchPersisted(for: Request) throws -> Self?
}

/// Add this middleware to your server to
/// persist and fetch persisted models that
/// conform to the `Persistable` protocol.
public final class PersistMiddleware<U: Authenticatable & Persistable>: Middleware {
    public init(_ userType: U.Type = U.self) {}

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        if let user = try U.fetchPersisted(for: request) {
            request.auth.authenticate(user)
        }

        return try next.respond(to: request)
    }
}
