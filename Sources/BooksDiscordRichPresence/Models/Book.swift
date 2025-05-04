//
//  Book.swift
//  BooksDiscordRichPresence
//
//  Created by misaki on 01/05/25.
//

import Foundation

class Book: Identifiable {
    let id: Int
    var title: String
    var author: String
    var readingProgress: Float
    var updatedDate: Date
    var cover: String?

    init(
        id: Int, title: String, author: String, readingProgress: Float, updatedDate: Date,
        cover: String? = nil
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.readingProgress = readingProgress
        self.updatedDate = updatedDate
        self.cover = cover
    }
}
