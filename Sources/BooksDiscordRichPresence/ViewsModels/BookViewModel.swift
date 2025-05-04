//
//  BookFetcherService.swift
//  BooksDiscordRichPresence
//
//  Created by misaki on 01/05/25.
//

import Foundation
import SQLite

enum DatabaseError: LocalizedError, Identifiable {
    var id: String { localizedDescription }

    case connectionFailed(String)
    case queryFailed(String)

    var errorDescription: String? {
        switch self {
        case .connectionFailed(let reason):
            return "Failed to connect with database: \(reason)"
        case .queryFailed(let reason):
            return "Failed while trying to execute query: \(reason)"
        }
    }
}

class BookViewModel: ObservableObject {
    @Published var error: DatabaseError?
    @Published var book: Book!

    private let databaseService = DatabaseService()

    func fetchFirstBook() async throws {
        do {
            guard let firstBook = try await databaseService.fetchFirstBook() else {
                throw DatabaseError.queryFailed("No books found.")
            }

            let cover = await BookCoverService.fetchCoverByTitle(for: firstBook.title)

            let updatedBook = firstBook
            updatedBook.cover = cover

            await MainActor.run {
                self.book = updatedBook
            }

        } catch let error as DatabaseError {
            throw error
        } catch {
            throw DatabaseError.queryFailed(error.localizedDescription)
        }
    }
}
