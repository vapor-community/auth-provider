import HTTP
import Authentication

/// Requires a `Authorization: Bearer ...` header and authenticates
/// the supplied User type using the `TokenAuthenticatable` protocol.
public final class TokenAuthenticationMiddleware<U: TokenAuthenticatable>: Middleware {
    public init(_ userType: U.Type = U.self) {}

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let token = request.auth.header?.bearer else {
            throw AuthenticationError.invalidCredentials
        }

        let u = try U.authenticate(token)

        request.auth.authenticate(u)

        return try next.respond(to: request)
    }
}

/// Similar to the `TokenAuthenticationMiddleware` but requires
/// a `Peristable` model and checks if the user is already 
/// authenticated prior to authenticating.
public final class TokenLoginMiddleware<U: TokenAuthenticatable & Persistable>: Middleware {
    public init(_ userType: U.Type = U.self) {}

    public func respond(to req: Request, chainingTo next: Responder) throws -> Response {
        // if the user has already been authenticated
        // by a previous middleware, continue
        if req.auth.isAuthenticated(U.self) {
            return try next.respond(to: req)
        }
        
        guard let token = req.auth.header?.bearer else {
            throw AuthenticationError.invalidCredentials
        }

        let u = try U.authenticate(token)

        try req.auth.authenticate(u, persist: true)

        return try next.respond(to: req)
    }
}
