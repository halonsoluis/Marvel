import Foundation

public struct MarvelCharacter: Equatable {
    public let id: Int?
    public let name: String?
    public let description: String?
    public let modified: String?
    public let thumbnail: URL?

    public init(id: Int?, name: String?, description: String?, modified: String?, thumbnail: URL?) {
        self.id = id
        self.name = name
        self.description = description
        self.modified = modified
        self.thumbnail = thumbnail
    }
}

public struct MarvelPublication: Equatable {
    public enum Kind: String, CaseIterable {
        case comics
        case events
        case series
        case stories
    }

    public let id: Int?
    public let title: String?
    public let modified: String?
    public let thumbnail: URL?

    public init(id: Int?, title: String?, modified: String?, thumbnail: URL?) {
        self.id = id
        self.title = title
        self.modified = modified
        self.thumbnail = thumbnail
    }
}

public typealias SingleCharacterFeedLoaderResult = (Result<MarvelCharacter?, Error>) -> Void
public typealias MultipleCharacterFeedLoaderResult = (Result<[MarvelCharacter], Error>) -> Void
public typealias MultiplePublicationFeedLoaderResult = (Result<[MarvelPublication], Error>) -> Void

public protocol CharacterFeedLoader {
    func character(id: Int, completion: @escaping SingleCharacterFeedLoaderResult)

    func characters(page: Int, completion: @escaping MultipleCharacterFeedLoaderResult)
    func search(by name: String, in page: Int, completion: @escaping MultipleCharacterFeedLoaderResult)

    func publication(characterId: Int, type: MarvelPublication.Kind, page: Int, completion: @escaping MultiplePublicationFeedLoaderResult)
}
