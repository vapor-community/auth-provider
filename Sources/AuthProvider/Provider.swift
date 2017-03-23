import Vapor

/// Nothing here yet, but add incase we anything
/// gets added in the future.
public final class Provider: Vapor.Provider {
    public init() {}

    public convenience init(config: Config) throws {
        self.init()
    }

    public func boot(_: Droplet) {}
    public func afterInit(_: Droplet) {}
    public func beforeRun(_: Droplet) {}
}
