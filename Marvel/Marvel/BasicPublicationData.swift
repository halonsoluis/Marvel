import Foundation

struct BasicPublicationData: Hashable, Equatable {
    let id: Int
    let title: String
    let imageFormula: ImageFormula

    public init(id: Int, title: String, imageFormula: ImageFormula) {
        self.id = id
        self.title = title
        self.imageFormula = imageFormula
    }

    init?(id: Int?, title: String?, thumbnail: URL?, modified: String?) {
        guard let id, let title, let thumbnail, let modified else {
            return nil
        }
        self.init(id: id, title: title, imageFormula: (url: thumbnail, uniqueKey: modified))
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(title)
        hasher.combine(imageFormula.uniqueKey)
    }

    static func == (lhs: BasicPublicationData, rhs: BasicPublicationData) -> Bool {
        lhs.id == rhs.id
    }
}
