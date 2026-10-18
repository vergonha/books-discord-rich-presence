<h1 align="center">
  <img src="https://cdn-icons-png.flaticon.com/512/5968/5968371.png" width="30px">
  books rich presence
  <img src="https://cdn-icons-png.flaticon.com/512/2111/2111370.png" width="30px">
</h1>
<div style="display: flex; align-items: center;">
    <img src="https://i.imgur.com/b0fbxug.png" style="align-self: flex-start;" />
</div>
<p align="center">
  a clean and modular swift app that sends reading progress to discord using ipc and mvvm.
</p>

---

## 𐔌՞. .՞𐦯 discord rich presence for books

this application is a lightweight, native macos app written in **swift** that displays your reading activity directly on discord.
it uses a custom-built **ipc client** to interface with the discord desktop app and follows the **mvvm** design pattern for separation of concerns and scalability.

you can display book titles, authors, reading progress, and cover art — all handled efficiently and with minimal dependencies.

this is my first swift project. i am currently learning the patterns, syntax, and best practices. i would greatly appreciate any pull requests or issues highlighting areas that could be improved or changed.

---

### ✮⋆˙ features ──

- direct ipc connection to discord (no 3rd-party wrappers)
- dynamic rich presence for current book
- displays title, author, cover image, and progress
- clean mvvm architecture
- modular swift files for transport, errors, and models
- lightweight and fast (no electron or heavy ui frameworks)

---

### 𖦹₊ ⊹ build & run ──

⤿ requirements

- macos sonoma+
- swift 5.8+
- discord desktop app installed

⤿ clone the repository

```bash
git clone https://github.com/vergonha/books-discord-rich-presence.git
```

⤿ build and run

```bash
cd books-discord-rich-presence

swift package resolve
swift build
swift run
```

> **note**: discord must be open before launching the app. ipc works only with the desktop client.

---

### ˚☽˚.⋆ how it works ──

the app searches the **ibooks database** located in the system's **library folder** to retrieve information about the **last opened book** on the machine. it automatically updates your discord status with the book's title, author, cover image, and reading progress.
