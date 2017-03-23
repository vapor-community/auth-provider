public enum AuthError: Error {
    case noRequest
    case unspecified(Error)
}

import Debugging

extension AuthError: Debuggable {
    public var reason: String {
        let reason: String

        switch self {
        case .noRequest:
            reason = "The authentication helper does not have a reference to the request"
        case .unspecified(let error):
            reason = "\(error)"
        }

        return "Auth error: \(reason)"
    }
    
    public var identifier: String {
        switch self {
        case .noRequest:
            return "noRequest"
        case .unspecified(let error):
            return "unspecified (\(error))"
        }
    }
    
    public var suggestedFixes: [String] {
        return []
    }
    
    public var possibleCauses: [String] {
        return []
    }
}
