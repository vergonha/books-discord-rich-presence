//
//  BooksDiscordRichPresenceApp.swift
//  BooksDiscordRichPresence
//
//  Created by misaki on 01/05/25.
//

import AppKit
import SwiftUI

@main
struct BooksDiscordRichPresenceApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            EmptyView()
        }
    }
}
