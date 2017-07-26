import HTTP
import Authentication

/// Redirects authenticated requests to a supplied path.
public final class InverseRedirectMiddleware<U: Authenticatable>: Middleware {
    /// The path to redirect to
    public let path: String

    /// Which type of redirect to perform
    public let redirectType: RedirectType

    /// Create a new inverse redirect middleware.
    public init(
        _ userType: U.Type = U.self,
        path: String,
        redirectType: RedirectType = .normal
    ) {
        self.path = path
        self.redirectType = redirectType
    }

    public func respond(to req: Request, chainingTo next: Responder) throws -> Response {
        guard !req.auth.isAuthenticated(U.self) else {
            return Response(redirect: path, redirectType)
        }

        return try next.respond(to: req)
    }

    /// Use this middleware to redirect authenticated
    /// away from login pages back to a secure home page.
    public static func home(_ userType: U.Type = U.self, path: String = "/") -> InverseRedirectMiddleware {
        return InverseRedirectMiddleware(U.self, path: path)
    }
}
