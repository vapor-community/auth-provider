import HTTP
import URI

extension Request {
    convenience init(_ method: Method, _ path: String) {
        let uri = URI(hostname: "0.0.0.0", path: path)
        self.init(method: method, uri: uri)
    }
}
