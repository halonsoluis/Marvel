//
//  BasicCharacterData.swift
//  Marvel
//
//  Created by Hugo Alonso on 12/12/2020.
//

import Foundation

struct BasicCharacterData: Hashable {
    let id: Int
    let name: String
    let imageFormula: (url: URL, uniqueKey: String)

    init?(id: Int?, name: String?, thumbnail: URL?, modified: String?) {
        guard let id = id, let name = name, let thumbnail = thumbnail, let modified = modified else { return nil }
        self.init(id: id, name: name, imageFormula: (url: thumbnail, uniqueKey: modified))
    }

    init(id: Int, name: String, imageFormula: (url: URL, uniqueKey: String)) {
        self.id = id
        self.name = name
        self.imageFormula = imageFormula
    }

    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    static func == (lhs: BasicCharacterData, rhs: BasicCharacterData) -> Bool {
        return lhs.id == rhs.id
    }
}
