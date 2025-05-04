//
//  BookCoverService.swift
//  BooksDiscordRichPresence
//
//  Created by misaki on 01/05/25.
//

import Foundation

class BookCoverService {
    static func fetchCoverByTitle(for title: String) async -> String? {
        guard let query = title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
            let url = URL(string: "https://openlibrary.org/search.json?q=\(query)")
        else {
            return nil
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let docs = json["docs"] as? [[String: Any]],
                let first = docs.first,
                let key = first["cover_edition_key"] as? String
            {
                return "https://covers.openlibrary.org/b/olid/\(key)-L.jpg"
            }
        } catch {
            return nil
        }

        return nil
    }
}
