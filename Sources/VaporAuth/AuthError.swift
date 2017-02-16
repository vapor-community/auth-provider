public enum AuthError: Error {
    case noRequest
    case unspecified(Error)
}

extension AuthError: CustomStringConvertible {
    public var description: String {
        let reason: String

        switch self {
        case .noRequest:
            reason = "The authentication helper does not have a reference to the request"
        case .unspecified(let error):
            reason = "\(error)"
        }

        return "Auth error: \(reason)"
    }
}

