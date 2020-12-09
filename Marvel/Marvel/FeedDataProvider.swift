//
//  FeedDataProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 09/12/2020.
//

import Foundation

struct BasicCharacterData: Hashable {
    let id: Int
    let name: String
    let thumbnail: URL
    let modified: String

    init?(id: Int?, name: String?, thumbnail: URL?, modified: String?) {
        guard let id = id, let name = name, let thumbnail = thumbnail, let modified = modified else { return nil }
        self.init(id: id, name: name, thumbnail: thumbnail, modified: modified)
    }

    init(id: Int, name: String, thumbnail: URL, modified: String) {
        self.id = id
        self.name = name
        self.thumbnail = thumbnail
        self.modified = modified
    }

    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    static func == (lhs: BasicCharacterData, rhs: BasicCharacterData) -> Bool {
        return lhs.id == rhs.id
    }
}

protocol FeedDataProvider: class {
    var items: [BasicCharacterData] { get }
    var onItemsChangeCallback: (() -> Void)? { get set }

    func perform(action: CharactersFeedUserAction)
}
