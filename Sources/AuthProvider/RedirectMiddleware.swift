import HTTP
import Authentication

/// Redirects unauthenticated requests to a supplied path.
public final class RedirectMiddleware: Middleware {
    /// The path to redirect to
    public let path: String

    /// Which type of redirect to perform
    public let redirectType: RedirectType

    /// Create a new redirect middleware.
    public init(
        path: String,
        redirectType: RedirectType = .normal
    ) {
        self.path = path
        self.redirectType = redirectType
    }

    public func respond(to req: Request, chainingTo next: Responder) throws -> Response {
        do {
            return try next.respond(to: req)
        } catch is AuthenticationError {
            return Response(redirect: path, redirectType)
        }
    }

    /// Use this middleware to redirect users away from 
    /// protected content to a login page
    public static func login(path: String = "/login") -> RedirectMiddleware {
        return RedirectMiddleware(path: path)
    }
}
