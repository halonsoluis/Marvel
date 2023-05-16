import Foundation

struct MarvelCharacterItem: Codable {
    let id: Int?
    let name: String?
    let description: String?
    let modified: String?
    let thumbnail: Image?

    let urls: [LinkURL]?
}
