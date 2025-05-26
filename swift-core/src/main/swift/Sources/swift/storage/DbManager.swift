import Foundation
import SwiftFMDB

actor DbManager {

    private let dbPathprovider: DbPathProvider
    private let dbName: String

    private var queue: FMDatabaseQueue?

    private let dbInitBlock: ((FMDatabase) -> Void)?

    init(dbPathprovider: DbPathProvider, dbName: String, dbInitBlock: ((FMDatabase) -> Void)? = nil)
    {
        self.dbPathprovider = dbPathprovider
        self.dbName = dbName
        self.dbInitBlock = dbInitBlock
    }

    public func updateDb(transaction: @escaping (FMDatabase) throws -> Void) async throws {
        let queue = try await getDbQueue()
        try await _updateDb(queue: queue, transaction: transaction)
    }

    private func getDbQueue() async throws -> FMDatabaseQueue {
        if let queue = queue {
            return queue
        }

        let dbPath = dbPathprovider.getPathForDb(withName: dbName)
        let dbQueue = FMDatabaseQueue.databaseQueue(withPath: dbPath)!
        self.queue = dbQueue

        if let dbInitBlock = dbInitBlock {
            try await _updateDb(queue: dbQueue, transaction: dbInitBlock)
        }

        return dbQueue
    }

    private func _updateDb(
        queue: FMDatabaseQueue,
        transaction: @escaping (FMDatabase) throws -> Void
    ) async throws {
        try await withCheckedThrowingContinuation { continuation in
            // Offload sync operation to a background thread
            DispatchQueue.global().async {
                queue.inDatabase { db in
                    do {
                        try transaction(db)
                        continuation.resume()
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
