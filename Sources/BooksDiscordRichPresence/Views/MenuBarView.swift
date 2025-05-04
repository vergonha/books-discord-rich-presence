import SwiftUI

struct MenuBarView: View {
    @ObservedObject var appDelegate: AppDelegate
    @State private var isHovered: Bool = false
    @State private var isAwaiting: Bool = true
    @StateObject private var bookViewModel = BookViewModel()

    var body: some View {
        VStack(spacing: 12) {
            RichPresencePreviewView(book: appDelegate.currentBook)

            Divider()
                .background(Color.gray.opacity(0.3))

            Toggle(isOn: $appDelegate.isRichPresenceEnabled) {
                Text("Enable Rich Presence")
                    .foregroundColor(.white)
            }
            .toggleStyle(SwitchToggleStyle())
            .onChange(of: appDelegate.isRichPresenceEnabled) {
                appDelegate.toggleRichPresence()
            }
            .padding(.horizontal, 4)
            .onHover { isHovered in
                self.isHovered = isHovered
                updateCursor(isHovered: isHovered)
            }
            .disabled(self.isAwaiting)

            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            .frame(maxWidth: .infinity)
            .disabled(self.isAwaiting)

            Button("Quit App") {
                NSApplication.shared.terminate(nil)
            }
            .buttonStyle(.borderless)
            .foregroundColor(.red)
            .font(.system(size: 12))
            .padding(.top, -4)
            .onHover { isHovered in
                self.isHovered = isHovered
                updateCursor(isHovered: isHovered)
            }
        }
        .padding(12)
        .frame(width: 300)
        .background(Color(red: 0.1, green: 0.1, blue: 0.11))
        .onAppear {
            fetchCurrentBook()
        }
    }

    private func fetchCurrentBook() {
        Task {
            try await bookViewModel.fetchFirstBook()
            if !(bookViewModel.book == nil) {
                self.isAwaiting = false

                DispatchQueue.main.async {
                    appDelegate.setCurrentBook(book: bookViewModel.book)
                }
            }
        }
    }

    private func updateCursor(isHovered: Bool) {
        if isHovered {
            NSCursor.pointingHand.push()
        } else {
            NSCursor.pop()
        }

    }
}
