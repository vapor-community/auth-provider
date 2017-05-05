import Vapor

extension BCryptHasher: PasswordVerifier {
    public func verify(password: Bytes, matches hash: Bytes) throws -> Bool {
        return try check(password, matchesHash: hash)
    }
}
