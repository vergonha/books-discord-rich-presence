import AppKit
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate, ObservableObject {
    private var statusItem: NSStatusItem!
    private var popover: NSPopover!
    private var discordService: DiscordTransportService?

    private var timer: Timer?

    @Published var currentBook: Book?
    @Published var isRichPresenceEnabled = false
    @objc private func timerFired() { updateRichPresence() }

    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = statusItem.button {
            if popover.isShown {
                popover.performClose(sender)
            } else {
                popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                popover.contentViewController?.view.window?.makeKey()
            }
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        setupMenuBarItem()
        setupPopover()
    }

    private func setupMenuBarItem() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "book", accessibilityDescription: "Books")
            button.action = #selector(togglePopover(_:))
        }
    }

    private func setupPopover() {
        popover = NSPopover()
        popover.contentSize = NSSize(width: 300, height: 60)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(
            rootView: MenuBarView(appDelegate: self))
    }

    func toggleRichPresence() {
        isRichPresenceEnabled.toggle()

        if isRichPresenceEnabled {
            weak var weakSelf = self
            Task {
                await enableRichPresence()
                DispatchQueue.main.async {
                    guard let strongSelf = weakSelf else { return }
                    strongSelf.startRefreshTimer()
                }
            }
        } else {
            disableRichPresence()
            stopRefreshTimer()
        }
    }

    func setCurrentBook(book: Book) {
        DispatchQueue.main.async {
            self.currentBook = book
        }
    }

    private func startRefreshTimer() {
        stopRefreshTimer()
        timer = Timer.scheduledTimer(
            timeInterval: 5, target: self, selector: #selector(timerFired), userInfo: nil,
            repeats: true)

        RunLoop.main.add(timer!, forMode: .common)
        updateRichPresence()
    }

    private func stopRefreshTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func updateRichPresence() {
        Task {
            let viewModel = BookViewModel()
            do {
                try await viewModel.fetchFirstBook()
                guard viewModel.book != nil else { return }

                // Only update if book changed or have progress in current reading.
                if let currentBook = self.currentBook,
                    viewModel.book.id == currentBook.id
                        && viewModel.book.readingProgress == currentBook.readingProgress
                {
                    return
                }

                // Update on main thread for UI updates
                DispatchQueue.main.async {
                    self.currentBook = viewModel.book
                }

                if let book = viewModel.book,
                    let discordService = self.discordService
                {
                    let activityPayload = try discordService.createActivityPayload(for: book)
                    discordService.send(op: .FRAME, payload: activityPayload)
                    print("Rich Presence updated with new book: \(book.title)")
                }
            } catch {
                print("Error updating Rich Presence: \(error.localizedDescription)")
            }
        }
    }

    func enableRichPresence() async {
        let viewModel = BookViewModel()
        do {
            if self.currentBook == nil {
                try await viewModel.fetchFirstBook()
                self.currentBook = viewModel.book
            }

            let service = DiscordTransportService(clientId: "1367685404538568785")
            self.discordService = service

            guard let current = self.currentBook else { return }
            let activityPayload = try service.createActivityPayload(for: current)

            try service.connect { result in
                switch result {
                case .success(let payload):
                    print("Received from Discord: \(payload)")
                    if payload.op == 1 {
                        if let cmd = payload.data["cmd"] as? String,
                            cmd != "SET_ACTIVITY"
                        {
                            print(activityPayload)
                            service.send(op: .FRAME, payload: activityPayload)
                        }
                    }
                case .failure(let error):
                    print("Discord connection error: \(error)")
                }
            }
        } catch {
            print("Failed to enable Discord Rich Presence: \(error.localizedDescription)")
        }
    }

    func disableRichPresence() {
        if let service = discordService {
            service.end()
            self.discordService = nil
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        stopRefreshTimer()
        disableRichPresence()
    }
}
