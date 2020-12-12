//
//  BasicPublicationData.swift
//  Marvel
//
//  Created by Hugo Alonso on 12/12/2020.
//

import Foundation

struct BasicPublicationData: Hashable {
    let id: Int
    let title: String
    let imageFormula: ImageFormula

    public init(id: Int, title: String, imageFormula: ImageFormula) {
        self.id = id
        self.title = title
        self.imageFormula = imageFormula
    }

    init?(id: Int?, title: String?, thumbnail: URL?, modified: String?) {
        guard let id = id, let title = title, let thumbnail = thumbnail, let modified = modified else { return nil }
        self.init(id: id, title: title, imageFormula: (url: thumbnail, uniqueKey: modified))
    }

    func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }

    static func == (lhs: BasicPublicationData, rhs: BasicPublicationData) -> Bool {
        return lhs.id == rhs.id
    }
}
