//
//  Activity.swift
//  BooksDiscordRichPresence
//
//  Created by misaki on 02/05/25.
//

import Foundation

class DiscordActivity: Codable {
    var details: String?
    var state: String?
    var timestamps: Timestamps?
    var assets: Assets?
    var party: Party?
    var secrets: Secrets?
    var buttons: [Button]?
    var instance: Bool?

    class Timestamps: Codable {
        var start: Int?
        var end: Int?

        init(start: Int?, end: Int?) {
            self.start = start
            self.end = end
        }
    }

    class Assets: Codable {
        var large_image: String?
        var large_text: String?
        var small_image: String?
        var small_text: String?

        init(large_image: String?, large_text: String?, small_image: String?, small_text: String?) {
            self.large_image = large_image
            self.large_text = large_text
            self.small_image = small_image
            self.small_text = small_text
        }
    }

    class Party: Codable {
        var id: String?
        var size: [Int]?

        init(id: String?, size: [Int]?) {
            self.id = id
            self.size = size
        }
    }

    class Secrets: Codable {
        var join: String?
        var spectate: String?
        var match: String?

        init(join: String?, spectate: String?, match: String?) {
            self.join = join
            self.spectate = spectate
            self.match = match
        }
    }

    class Button: Codable {
        var label: String
        var url: String

        init(label: String, url: String) {
            self.label = label
            self.url = url
        }
    }

    // MARK: - Fluent Setters
    @discardableResult
    func setDetails(_ details: String) -> Self {
        self.details = details
        return self
    }

    @discardableResult
    func setState(_ state: String) -> Self {
        self.state = state
        return self
    }

    @discardableResult
    func setTimestamps(start: Int?, end: Int?) -> Self {
        self.timestamps = Timestamps(start: start, end: end)
        return self
    }

    @discardableResult
    func setAssets(largeImage: String?, largeText: String?, smallImage: String?, smallText: String?)
        -> Self
    {
        self.assets = Assets(
            large_image: largeImage,
            large_text: largeText,
            small_image: smallImage,
            small_text: smallText
        )
        return self
    }

    @discardableResult
    func setParty(id: String, size: [Int]) -> Self {
        self.party = Party(id: id, size: size)
        return self
    }

    @discardableResult
    func setSecrets(join: String?, spectate: String?, match: String?) -> Self {
        self.secrets = Secrets(join: join, spectate: spectate, match: match)
        return self
    }

    @discardableResult
    func setButtons(_ buttons: [Button]) -> Self {
        self.buttons = Array(buttons.prefix(2))  // Discord only supports 2 buttons
        return self
    }

    @discardableResult
    func setInstance(_ instance: Bool) -> Self {
        self.instance = instance
        return self
    }

    // MARK: - JSON Builder
    func toJSON(pid: Int32) -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        var activityPayload: [String: Any] = [:]
        if let data = try? encoder.encode(self),
            let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        {
            activityPayload = dict
        }

        return [
            "cmd": "SET_ACTIVITY",
            "args": [
                "pid": pid,
                "activity": activityPayload,
            ],
            "nonce": UUID().uuidString,
        ]
    }
}
