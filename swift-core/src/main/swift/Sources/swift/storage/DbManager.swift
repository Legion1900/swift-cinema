import Foundation
import SwiftFMDB

enum DbError: Error {
    case databaseError(reason: String)
}

typealias TransactionBlock = (FMDatabase, inout Bool) throws -> Void

actor DbManager {

    private let dbPathprovider: DbPathProvider
    private let dbName: String

    private var queue: FMDatabaseQueue?

    private let dbInitBlock: TransactionBlock?

    init(
        dbPathprovider: DbPathProvider,
        dbName: String,
        dbInitBlock: TransactionBlock? = nil
    ) {
        self.dbPathprovider = dbPathprovider
        self.dbName = dbName
        self.dbInitBlock = dbInitBlock
    }

    func getDbQueue() async throws -> FMDatabaseQueue {
        if let queue = queue {
            return queue
        }

        let dbPath = dbPathprovider.getPathForDb(withName: dbName)
        let dbQueue = FMDatabaseQueue.databaseQueue(withPath: dbPath)!
        self.queue = dbQueue

        if let dbInitBlock = dbInitBlock {
            try await dbQueue.inTransaction(dbInitBlock)
        }

        return dbQueue
    }
}

// This method is moved to extension to allow multiple DB queries at a time. Actual DB parallelization is up for a user to configure.
extension DbManager {
    func transaction(
        _ transactionBlock: @escaping TransactionBlock
    ) async throws {
        let dbQueue = try await getDbQueue()
        try await dbQueue.inTransaction(transactionBlock)
    }
}

extension FMDatabaseQueue {
    func inTransaction(
        _ transactionBlock: @escaping TransactionBlock
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            // Offload potentially heavy sync operation to a background thread
            DispatchQueue.global().async {
                self.inTransaction { db, rollback in
                    do {
                        try transactionBlock(db, &rollback)

                        if rollback {
                            throw DbError.databaseError(
                                reason: "Transaction failed: \(String(describing: db.lastError()))")
                        }
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
