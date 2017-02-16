import HTTP
import Authentication

let authAuthenticatedKey = "auth-authenticated"
let authHelperKey = "auth-helper"

public final class Helper {
    weak var request: Request?
    public init(request: Request) {
        self.request = request
    }

    public var header: AuthorizationHeader? {
        guard let authorization = request?.headers["Authorization"] else {
            return nil
        }

        return AuthorizationHeader(string: authorization)
    }

    public func authenticate<A: Authenticatable>(_ a: A) {
        request?.storage[authAuthenticatedKey] = a
    }

    public func authenticate<AP: Authenticatable & Persistable>(_ ap: AP, persist: Bool) throws {
        request?.storage[authAuthenticatedKey] = ap
        if persist {
            guard let request = request else {
                throw AuthError.noRequest
            }
            try ap.persist(for: request)
        }
    }

    public func unauthenticate() {
        request?.storage[authAuthenticatedKey] = nil
    }

    public func authenticated<A: Authenticatable>(_ userType: A.Type = A.self) throws -> A {
        guard let a = request?.storage[authAuthenticatedKey] as? A else {
            throw AuthenticationError.notAuthenticated
        }

        return a
    }
}

extension Request {
    public var auth: Helper {
        if let existing = storage[authHelperKey] as? Helper {
            return existing
        }

        let helper = Helper(request: self)
        storage[authHelperKey] = helper

        return helper
    }
}
