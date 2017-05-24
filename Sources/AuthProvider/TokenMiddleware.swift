import HTTP
import Authentication

/// Requires a `Authorization: Bearer ...` header and authenticates
/// the supplied User type using the `TokenAuthenticatable` protocol.
public final class TokenAuthenticationMiddleware<U: TokenAuthenticatable>: Middleware {
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

        req.auth.authenticate(u)

        return try next.respond(to: req)
    }
}

public final class PasswordAuthenticationMiddleware<U: PasswordAuthenticatable>: Middleware {
    public let passwordVerifier: PasswordVerifier?
    public init(
        _ userType: U.Type = U.self,
        _ passwordVerifier: PasswordVerifier? = U.passwordVerifier
    ) {
        self.passwordVerifier = passwordVerifier
    }
    
    public func respond(to req: Request, chainingTo next: Responder) throws -> Response {
        // if the user has already been authenticated
        // by a previous middleware, continue
        if req.auth.isAuthenticated(U.self) {
            return try next.respond(to: req)
        }
        
        guard let password = req.auth.header?.basic else {
            throw AuthenticationError.invalidCredentials
        }
        
        let u = try U.authenticate(password)
        
        req.auth.authenticate(u)
        
        return try next.respond(to: req)
    }
}
