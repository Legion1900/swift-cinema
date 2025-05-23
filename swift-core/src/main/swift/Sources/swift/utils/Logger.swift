public protocol Logger: AnyObject {
    func log(_ message: String, withTag tag: String)
}

extension Logger {
    func log(_ message: String) {
        log(message, withTag: "SwiftCinema")
    }
}
