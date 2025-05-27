import Foundation
import SwiftFMDB

public protocol DbPathProvider {

    func getPathForDb(withName: String) -> String
}

public class MoviesStorage: Loggable {

    static var tag = "MoviesStorage"

    private static let DB_NAME = "movies.db"
    private static let tables: [Table.Type] = [
        ImageConfigRecord.self,
        MovieRecord.self,
    ]

    private static func initTables(_ db: FMDatabase, _ rollback: inout Bool) {
        let sqlStatements = Self.tables.map { $0.createTableQuery }
        var success = true
        for sql in sqlStatements {
            success = db.executeStatements(sql)

            if !success {
                break
            }
        }

        rollback = !success
    }

    private let dbPathprovider: DbPathProvider
    let logger: Logger

    private let dbManager: DbManager

    public init(dbPathprovider: DbPathProvider, logger: Logger) {
        self.dbPathprovider = dbPathprovider
        self.logger = logger

        dbManager = DbManager(
            dbPathprovider: dbPathprovider,
            dbName: Self.DB_NAME,
            dbInitBlock: Self.initTables
        )
    }

    func update(imgConfig: ImageConfigRecord) async throws {
        try await dbManager.transaction { db, rollback in

            db.executeUpdate(cached: true, "DELETE FROM \(ImageConfigRecord.TABLE_NAME);")

            let success = db.executeUpdate(
                cached: true,
                "INSERT INTO \(ImageConfigRecord.TABLE_NAME) (\(ImageConfigRecord.COLUMN_BASE_URL), \(ImageConfigRecord.COLUMN_MAX_POSTER_SIZE)) VALUES (?, ?);",
                withArgumentsInArray: [imgConfig.baseUrl, imgConfig.maxPosterSize])

            rollback = !success
        }
    }

    func getImageConfig() async throws -> ImageConfigRecord? {
        let sql = "SELECT * FROM \(ImageConfigRecord.TABLE_NAME) LIMIT 1;"

        return try await dbManager.query(sql) { set in
            return if set.next() {
                try ImageConfigRecord.from(currentRow: set)
            } else {
                nil
            }
        }
    }

    func addOrUpdate(movies: [MovieRecord]) async throws {
        try await dbManager.transaction { db, rollback in
            for movie in movies {
                let success = db.executeUpdate(
                    cached: true,
                    """
                    INSERT OR REPLACE INTO \(MovieRecord.TABLE_NAME)
                    (\(MovieRecord.COLUMN_SERVICE_ID), \(MovieRecord.COLUMN_TITLE), \(MovieRecord.COLUMN_OVERVIEW), \(MovieRecord.COLUMN_RELEASE_DATE), \(MovieRecord.COLUMN_POSTER_PATH), \(MovieRecord.COLUMN_AVERAGE_SCORE))
                    VALUES (:\(MovieRecord.COLUMN_SERVICE_ID), :\(MovieRecord.COLUMN_TITLE), :\(MovieRecord.COLUMN_OVERVIEW), :\(MovieRecord.COLUMN_RELEASE_DATE), :\(MovieRecord.COLUMN_POSTER_PATH), :\(MovieRecord.COLUMN_AVERAGE_SCORE));
                    """,
                    withParameterDictionary: [
                        MovieRecord.COLUMN_SERVICE_ID: movie.serviceId,
                        MovieRecord.COLUMN_TITLE: movie.title,
                        MovieRecord.COLUMN_OVERVIEW: movie.overview,
                        MovieRecord.COLUMN_RELEASE_DATE: movie.releaseDate,
                        MovieRecord.COLUMN_POSTER_PATH: movie.posterPath,
                        MovieRecord.COLUMN_AVERAGE_SCORE: movie.averageScore,
                    ]
                )

                if !success {
                    rollback = true
                    break
                }
            }
        }
    }

    func getMovies(offset: Int, limit: Int) async throws -> [MovieRecord] {
        let sql = """
            SELECT * FROM \(MovieRecord.TABLE_NAME)
            ORDER BY \(MovieRecord.COLUMN_RELEASE_DATE) DESC
            LIMIT ? OFFSET ?;
            """
        let args = [limit, offset]

        return try await dbManager.query(sql, withArgumentArray: args) { set in
            try MovieRecord.allFrom(resultSet: set)
        } ?? []
    }

    func getMoviesCount() async -> Int {
        let sql = "SELECT COUNT(\(MovieRecord.COLUMN_SERVICE_ID)) FROM \(MovieRecord.TABLE_NAME);"

        do {
            return try await dbManager.query(sql) { set in
                if set.next() {
                    return set.int(forColumnIndex: 0)
                } else {
                    return 0
                }
            } ?? 0
        } catch {
            log("Failed to get movies count: \(error)")
            return 0
        }
    }
}
