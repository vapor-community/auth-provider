import HTTP
import Authentication

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

public final class TokenLoginMiddleware<U: TokenAuthenticatable & Persistable>: Middleware {
    public init(_ userType: U.Type = U.self) {}

    public func respond(to request: Request, chainingTo next: Responder) throws -> Response {
        guard let token = request.auth.header?.bearer else {
            return try next.respond(to: request)
        }

        let u = try U.authenticate(token)

        try request.auth.authenticate(u, persist: true)

        return try next.respond(to: request)
    }
}
