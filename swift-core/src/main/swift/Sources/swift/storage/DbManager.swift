import Foundation
import SwiftFMDB

enum DbError: Error {
    case databaseError(reason: String)
}

actor DbManager {

    private let dbPathprovider: DbPathProvider
    private let dbName: String

    private let logger: Logger

    private var queue: FMDatabaseQueue?

    private let dbInitBlock: ((FMDatabase) -> Bool)?

    init(
        dbPathprovider: DbPathProvider, dbName: String, withLogger logger: Logger,
        dbInitBlock: ((FMDatabase) -> Bool)? = nil
    ) {
        self.dbPathprovider = dbPathprovider
        self.dbName = dbName
        self.dbInitBlock = dbInitBlock
        self.logger = logger
    }

    public func transaction(transaction: @escaping (FMDatabase) throws -> Bool) async throws {
        let queue = try await getDbQueue()
        try await _transaction(queue: queue, transaction: transaction)
    }

    private func getDbQueue() async throws -> FMDatabaseQueue {
        if let queue = queue {
            return queue
        }

        let dbPath = dbPathprovider.getPathForDb(withName: dbName)
        let dbQueue = FMDatabaseQueue.databaseQueue(withPath: dbPath)!
        self.queue = dbQueue

        if let dbInitBlock = dbInitBlock {
            try await _transaction(queue: dbQueue, transaction: dbInitBlock)
        }

        return dbQueue
    }

    private func _transaction(
        queue: FMDatabaseQueue,
        transaction: @escaping (FMDatabase) throws -> Bool
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            // Offload sync operation to a background thread
            DispatchQueue.global().async {
                queue.inTransaction { db, rollback in
                    do {
                        let success = try transaction(db)

                        self.logger.log("Transaction completed successfully: \(success)")

                        if !success {
                            throw DbError.databaseError(
                                reason: "Transaction failed: \(String(describing: db.lastError()))")
                        }
                        continuation.resume()
                    } catch {
                        rollback = true
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
