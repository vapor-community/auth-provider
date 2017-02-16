import Vapor

public final class Provider: Vapor.Provider {
    public init() {}

    public convenience init(config: Config) throws {
        self.init()
    }

    public func boot(_: Droplet) {}
    public func afterInit(_: Droplet) {}
    public func beforeRun(_: Droplet) {}
}
