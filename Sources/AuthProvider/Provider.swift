import Vapor

/// Nothing here yet, but add in case anything
/// gets added in the future.
public final class Provider: Vapor.Provider {
    public static let repositoryName = "auth-provider"

    public init() {}

    public convenience init(config: Config) throws {
        self.init()
    }

    public func boot(_ config: Config) throws {}
    public func boot(_ drop: Droplet) throws {}
    public func beforeRun(_ drop: Droplet) throws {}
}
