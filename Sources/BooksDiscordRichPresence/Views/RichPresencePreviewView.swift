//
//  RichPresencePreviewView.swift
//  BooksDiscordRichPresence
//
//  Created by misaki on 03/05/25.
//

import Foundation
import SwiftUI

struct RichPresencePreviewView: View {
    let book: Book?

    init(book: Book? = nil) {
        self.book = book
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PREVIEW")
                .font(.system(size: 11))
                .foregroundColor(.gray)
                .padding(.top, 5)

            HStack(alignment: .top, spacing: 12) {
                coverImageView

                VStack(alignment: .leading, spacing: 4) {
                    Text("Apple Books")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)

                    if let book = book {
                        Text(book.title)
                            .font(.system(size: 12))
                            .foregroundColor(.white)
                            .lineLimit(1)

                        Text(book.author)
                            .font(.system(size: 11))
                            .foregroundColor(.gray)
                            .lineLimit(1)

                        HStack(spacing: 4) {
                            Text("Progress:")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)

                            Text("\(Int(book.readingProgress * 100))%")
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }

                    } else {
                        Text("Fetching...")
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.vertical, 4)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(red: 0.15, green: 0.15, blue: 0.17))
        )
    }

    private var coverImageView: some View {
        Group {
            if let book = self.book, let url = URL(string: book.cover ?? "") {
                AsyncImage(url: url) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    coverPlaceholder
                }
                .frame(width: 60, height: 80)
                .cornerRadius(4)
            } else {
                coverPlaceholder
            }
        }
    }

    private var coverPlaceholder: some View {
        Rectangle()
            .fill(Color(red: 0.2, green: 0.2, blue: 0.22))
            .frame(width: 60, height: 80)
            .cornerRadius(4)
            .overlay(
                Image(systemName: "book.closed")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            )
    }
}
