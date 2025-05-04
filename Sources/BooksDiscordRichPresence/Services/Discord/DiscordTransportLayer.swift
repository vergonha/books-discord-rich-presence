//
//  DiscordTransportLayer.swift
//  BooksDiscordRichPresence
//
//  Created by misaki on 01/05/25.
//

import Foundation

struct IPCPayload {
    let op: Int32
    let data: [String: Any]
}

enum DiscordOpcode: Int32 {
    case HANDSHAKE = 0
    case FRAME = 1
    case CLOSE = 2
    case PING = 3
    case PONG = 4
}

enum DiscordError: LocalizedError, Identifiable, Error {
    var id: String { errorDescription ?? UUID().uuidString }

    case ipcNotFound
    case connectionFailed
    case socketPathTooLong
    case jsonEncodingFailed
    case jsonDecodingFailed
    case invalidJsonObject
    case bufferTooShort
    case incompletePayload

    var errorDescription: String? {
        switch self {
        case .ipcNotFound:
            return "IPC socket not found in expected paths."
        case .connectionFailed:
            return "Failed to connect to the Discord IPC socket."
        case .socketPathTooLong:
            return "The IPC socket path is too long."
        case .jsonEncodingFailed:
            return "Failed to encode JSON payload."
        case .jsonDecodingFailed:
            return "Failed to decode JSON payload."
        case .invalidJsonObject:
            return "Received JSON is not a valid object."
        case .bufferTooShort:
            return "Payload buffer is too short to contain valid data."
        case .incompletePayload:
            return "Payload does not contain the full message as indicated by the length field."
        }
    }
}

class DiscordTransportService {
    var ipcSource: DispatchSourceRead?
    var socketFD: Int32?
    var clientId: String

    init(clientId: String) {
        self.clientId = clientId
    }

    private func getIpcPath(_ id: Int) -> String {
        let env = ProcessInfo.processInfo.environment
        let prefix = env["XDG_RUNTIME_DIR"] ?? env["TMPDIR"] ?? env["TMP"] ?? env["TEMP"] ?? "/tmp"
        return "\(prefix.hasSuffix("/") ? String(prefix.dropLast()) : prefix)/discord-ipc-\(id)"
    }

    private func attemptToGetIpcPath(maxRetries: Int = 9) throws -> String {
        for id in 0..<maxRetries {
            let path = self.getIpcPath(id)
            let file = FileManager().fileExists(atPath: path)
            if file { return path }
        }

        throw DiscordError.ipcNotFound
    }

    private func connectToIpc(at path: String) throws -> (
        socketFD: Int32, source: DispatchSourceRead
    ) {
        let fd = socket(AF_UNIX, SOCK_STREAM, 0)
        guard fd >= 0 else { throw DiscordError.connectionFailed }

        var addr = sockaddr_un()
        addr.sun_family = sa_family_t(AF_UNIX)

        let maxLength = MemoryLayout.size(ofValue: addr.sun_path)
        let socketPath = path.utf8CString
        guard socketPath.count <= maxLength else {
            close(fd)
            throw DiscordError.socketPathTooLong
        }

        socketPath.withUnsafeBufferPointer { buffer in
            strncpy(&addr.sun_path.0, buffer.baseAddress, maxLength)
        }

        let size = socklen_t(MemoryLayout<sockaddr_un>.size)
        let result = withUnsafePointer(to: &addr) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                Foundation.connect(fd, $0, size)
            }
        }

        guard result >= 0 else {
            close(fd)
            throw DiscordError.connectionFailed
        }

        let source = DispatchSource.makeReadSource(fileDescriptor: fd, queue: .main)
        return (fd, source)
    }

    private func encodePayload(op: DiscordOpcode, payload: [String: Any]) throws -> Data {
        guard let json = try? JSONSerialization.data(withJSONObject: payload) else {
            throw DiscordError.jsonEncodingFailed
        }

        var buffer = Data()

        var op: Int32 = op.rawValue
        var length = UInt32(json.count)

        withUnsafeBytes(of: &op) { buffer.append(contentsOf: $0) }
        withUnsafeBytes(of: &length) { buffer.append(contentsOf: $0) }
        buffer.append(json)

        return buffer
    }

    private func decodePayload(from buffer: Data) throws -> IPCPayload {
        guard buffer.count >= 8 else {
            throw DiscordError.bufferTooShort
        }

        let op = buffer.withUnsafeBytes { $0.load(as: Int32.self) }
        let length = buffer.advanced(by: 4).withUnsafeBytes { $0.load(as: Int32.self) }

        guard buffer.count >= 8 + Int(length) else {
            throw DiscordError.incompletePayload
        }

        let jsonData = buffer.subdata(in: 8..<(8 + Int(length)))

        guard let object = try? JSONSerialization.jsonObject(with: jsonData) else {
            throw DiscordError.jsonDecodingFailed
        }

        guard let dict = object as? [String: Any] else {
            throw DiscordError.invalidJsonObject
        }

        return IPCPayload(op: op, data: dict)
    }

    private func handshake() throws {
        let payload: [String: Any] = [
            "v": 1,
            "client_id": clientId,
        ]

        send(op: DiscordOpcode.HANDSHAKE, payload: payload)
    }

    func createActivityPayload(for book: Book) throws -> [String: Any] {
        var activity = DiscordActivity()
            .setState(book.author)
            .setDetails("\(book.title) (\(String(format: "%.0f", book.readingProgress * 100))%)")
            .setAssets(
                largeImage: book.cover,
                largeText: book.title,
                smallImage:
                    "https://help.apple.com/assets/67368A9179C56FB1B106D02B/67368A97231AFF3D8A0ADB76/pt_BR/3805d456c1f34d7f9d4f023a12a0bb67.png",
                smallText: "Books (Application)"
            )

        return activity.toJSON(pid: getpid())

    }

    func send(op: DiscordOpcode, payload: [String: Any]) {
        do {
            guard let fd = self.socketFD else { throw DiscordError.ipcNotFound }
            let data = try encodePayload(op: op, payload: payload)
            _ = data.withUnsafeBytes {
                write(fd, $0.baseAddress, data.count)
            }
        } catch {
            print(error)
        }
    }

    func end() {
        ipcSource?.cancel()
        if let fd = socketFD {
            Darwin.close(fd)
        }
        ipcSource = nil
        socketFD = nil
    }

    func connect(onReceive: @escaping (Result<IPCPayload, Error>) -> Void) throws {
        do {
            let path = try self.attemptToGetIpcPath()
            let (fd, source) = try connectToIpc(at: path)

            self.socketFD = fd
            self.ipcSource = source
            try self.handshake()

            source.setEventHandler {
                var buffer = [UInt8](repeating: 0, count: 4096)
                let count = read(fd, &buffer, buffer.count)
                if count > 0 {
                    let data = Data(buffer.prefix(count))
                    do {
                        let decoded = try self.decodePayload(from: data)
                        onReceive(.success(decoded))
                    } catch {
                        source.cancel()
                        onReceive(.failure(DiscordError.jsonDecodingFailed))
                    }
                } else {
                    print("Connection closed.")
                    source.cancel()
                }
            }

            source.setCancelHandler {
                close(fd)
            }

            source.resume()
        } catch {
            throw error
        }
    }
}
