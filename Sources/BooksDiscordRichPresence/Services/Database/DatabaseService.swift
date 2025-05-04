//
//  DatabaseService.swift
//  BooksDiscordRichPresence
//
//  Created by misaki on 02/05/25.
//

import Foundation
import SQLite

class DatabaseService {
    private var db: Connection?

    private let id = Expression<Int64>("Z_PK")
    private let title = Expression<String?>("ZTITLE")
    private let author = Expression<String?>("ZAUTHOR")
    private let progress = Expression<Double?>("ZREADINGPROGRESS")
    private let updatedDate = Expression<Double?>("ZLASTOPENDATE")

    init() {
        connect()
    }

    private func connect() {
        let dbLocation = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(
                "Library/Containers/com.apple.iBooksX/Data/Documents/BKLibrary/BKLibrary-1-091020131601.sqlite"
            )

        if dbLocation.startAccessingSecurityScopedResource() {
            let path = dbLocation.path

            do {
                db = try Connection(path, readonly: true)
            } catch {
                print("Database connection failed: \(error.localizedDescription)")
            }
        }
    }

    func fetchFirstBook() async throws -> Book? {
        guard let db = db else {
            throw DatabaseError.connectionFailed("Database connection not established")
        }

        let query = Table("ZBKLIBRARYASSET")
            .order(updatedDate.desc)
            .limit(1)

        if let row = try db.pluck(query) {
            let titleVal = row[title] ?? "No title"
            let authorVal = row[author] ?? "Unknown"
            let progressVal = Float(row[progress] ?? 0.0)
            let updatedVal = Date(timeIntervalSinceReferenceDate: (row[updatedDate] ?? 0.0))

            return Book(
                id: Int(row[id]),
                title: titleVal,
                author: authorVal,
                readingProgress: progressVal,
                updatedDate: updatedVal
            )
        }

        return nil
    }

    func fetchBooks() async throws -> [Book] {
        guard let db = db else {
            throw DatabaseError.connectionFailed("Database connection not established")
        }

        return try db.prepare(Table("ZBKLIBRARYASSET").order(updatedDate.desc)).map { row in
            let titleVal = row[title] ?? "No title"
            let authorVal = row[author] ?? "Unknown"
            let progressVal = Float(row[progress] ?? 0.0)
            let updatedVal = Date(timeIntervalSinceReferenceDate: (row[updatedDate] ?? 0.0))

            return Book(
                id: Int(row[id]),
                title: titleVal,
                author: authorVal,
                readingProgress: progressVal,
                updatedDate: updatedVal
            )
        }
    }
}
