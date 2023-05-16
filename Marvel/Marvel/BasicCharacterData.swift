import Foundation

struct BasicCharacterData: Hashable, Equatable {
    let id: Int
    let name: String
    let description: String
    let imageFormula: ImageFormula

    init?(id: Int?, name: String?, description: String?, thumbnail: URL?, modified: String?) {
        guard let id, let name, let description, let thumbnail, let modified else {
            return nil
        }
        self.init(id: id, name: name, description: description, imageFormula: (url: thumbnail, uniqueKey: modified))
    }

    init(id: Int, name: String, description: String, imageFormula: ImageFormula) {
        self.id = id
        self.name = name
        self.description = description
        self.imageFormula = imageFormula
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(description)
        hasher.combine(imageFormula.uniqueKey)
    }

    static func == (lhs: BasicCharacterData, rhs: BasicCharacterData) -> Bool {
        lhs.id == rhs.id
    }
}
