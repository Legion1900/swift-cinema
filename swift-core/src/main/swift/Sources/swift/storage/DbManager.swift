import Foundation
import SwiftFMDB

enum DbError: Error {
    case databaseError(reason: String)
    case queryMapingError(reason: String)
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

    func query<Result>(
        _ sql: String,
        withArgumentArray args: [Any?] = [],
        cached: Bool = true,
        mapWith mapBlock: @escaping (FMResultSet) throws -> Result?
    ) async throws -> Result? {
        let dbQueue = try await getDbQueue()
        return try await dbQueue.inDatabase { db in
            guard let resultSet = db.executeQuery(cached: cached, sql, withArgumentsInArray: args)
            else {
                throw DbError.databaseError(
                    reason: "Query failed: \(String(describing: db.lastError()))")
            }

            defer { resultSet.close() }

            do {
                return try mapBlock(resultSet)
            } catch {
                throw DbError.queryMapingError(
                    reason: "Mapping result set failed: \(error.localizedDescription)")
            }
        }
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

    func inDatabase<Result>(
        _ block: @escaping (FMDatabase) throws -> Result
    ) async throws -> Result {
        try await withCheckedThrowingContinuation { continuation in
            // Offload potentially heavy sync operation to a background thread
            DispatchQueue.global().async {
                self.inDatabase { db in
                    do {
                        let result = try block(db)
                        continuation.resume(returning: result)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                }
            }
        }
    }
}
