import HTTP
import Authentication

let authUserKey = "auth-user"
let authHelperKey = "auth-helper"

public final class Helper {
    weak var request: Request?
    public init(request: Request) {
        self.request = request
    }

    public var header: Authorization? {
        guard let authorization = request?.headers["Authorization"] else {
            return nil
        }

        return Authorization(header: authorization)
    }

    public func login<U: Authenticatable>(_ user: U) {
        request?.storage[authUserKey] = user
    }

    public func login<U: Authenticatable & Persistable>(_ user: U, persist: Bool) throws {
        request?.storage[authUserKey] = user
        if persist {
            guard let request = request else {
                throw AuthError.noRequest
            }
            try user.persist(for: request)
        }
    }

    public func logout() {
        request?.storage[authUserKey] = nil
    }

    public func user<U: Authenticatable>(_ userType: U.Type = U.self) throws -> U {
        guard let user = request?.storage[authUserKey] as? U else {
            throw AuthenticationError.notAuthenticated
        }

        return user
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
