//
//  BasicCharacterData.swift
//  Marvel
//
//  Created by Hugo Alonso on 12/12/2020.
//

import Foundation

struct BasicCharacterData: Hashable, Equatable {
    let id: Int
    let name: String
    let description: String
    let imageFormula: ImageFormula

    init?(id: Int?, name: String?, description: String?, thumbnail: URL?, modified: String?) {
        guard let id = id, let name = name, let description = description, let thumbnail = thumbnail, let modified = modified else { return nil }
        self.init(id: id, name: name, description: description, imageFormula: (url: thumbnail, uniqueKey: modified))
    }

    init(id: Int, name: String, description: String, imageFormula: ImageFormula) {
        self.id = id
        self.name = name
        self.description = description
        self.imageFormula = imageFormula
    }

    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    static func == (lhs: BasicCharacterData, rhs: BasicCharacterData) -> Bool {
        return lhs.id == rhs.id
    }
}
