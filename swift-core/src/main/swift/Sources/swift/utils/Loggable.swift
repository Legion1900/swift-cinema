protocol Loggable: AnyObject {
    static var tag: String { get }
    var logger: Logger { get }
}

extension Loggable {
    func log(
        _ message: String
    ) {
        logger.log(message, withTag: Self.tag)
    }
}
