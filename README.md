<h1 align="center">
  <img src="https://cdn-icons-png.flaticon.com/512/5968/5968371.png" width="30px">
  Books Rich Presence
  <img src="https://cdn-icons-png.flaticon.com/512/2111/2111370.png" width="30px">
</h1>
<div style="display: flex; align-items: center;">
    <img src="https://i.imgur.com/b0fbxug.png" style="align-self: flex-start;" />
</div>

</div>
<p align="center">
  A clean and modular Swift app that sends reading progress to Discord using IPC and MVVM.
</p>

---

## 📚 Discord Rich Presence for Books

This application is a lightweight, native macOS app written in **Swift** that displays your reading activity directly on Discord.
It uses a custom-built **IPC client** to interface with the Discord desktop app and follows the **MVVM** design pattern for separation of concerns and scalability.

You can display book titles, authors, reading progress, and cover art — all handled efficiently and with minimal dependencies.

This is my first Swift project. I am currently learning the patterns, syntax, and best practices. I would greatly appreciate any pull requests or issues highlighting areas that could be improved or changed.

---

## 🚀 Features

- 🔌 Direct IPC connection to Discord (no 3rd-party wrappers)
- 📖 Dynamic Rich Presence for current book
- 🖼️ Displays title, author, cover image, and progress
- 🧠 Clean MVVM architecture
- 🧩 Modular Swift files for transport, errors, and models
- 🪶 Lightweight and fast (no Electron or heavy UI frameworks)

## 🛠️ Build & Run

### 📦 Requirements

- macOS Sonoma+
- Swift 5.8+
- Discord Desktop App installed

### 🧱 Build Steps

- Clone the repository:

```bash
git clone https://github.com/vergonha/books-discord-rich-presence.git
```

- Build and run:

```bash
cd books-discord-rich-presence

swift package resolve
swift build
swift run
```

> ⚠️ **Note**: Discord must be open before launching the app. IPC works only with the desktop client.

## ⚙️ How It Works

The app searches the **iBooks database** located in the system’s **Library folder** to retrieve information about the **last opened book** on the machine. It automatically updates your Discord status with the book’s title, author, cover image, and reading progress.
