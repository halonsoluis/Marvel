import Foundation

enum RouteComposer: Equatable {
    /// Fetches lists of characters.
    case characters
    /// Fetches a single character by id.
    case character(id: Int)

    /// Fetches lists of comics filtered by a character id.
    case comics(characterId: Int)

    /// Fetches lists of events filtered by a character id.
    case events(characterId: Int)

    /// Fetches lists of series filtered by a character id.
    case series(characterId: Int)

    /// Fetches lists of stories filtered by a character id.
    case stories(characterId: Int)

    func url(from baseURL: URL) -> URL {
        switch self {
        case .characters:
            return characters(from: baseURL)
        case let .character(id):
            return character(id: id, from: baseURL)
        case let .comics(characterId: id):
            return endpoint("comics", id: id, from: baseURL)
        case let .events(characterId: id):
            return endpoint("events", id: id, from: baseURL)
        case let .series(characterId: id):
            return endpoint("series", id: id, from: baseURL)
        case let .stories(characterId: id):
            return endpoint("stories", id: id, from: baseURL)
        }
    }

    private func characters(from baseURL: URL) -> URL {
        baseURL.appendingPathComponent("characters")
    }

    private func character(id: Int, from baseURL: URL) -> URL {
        characters(from: baseURL)
            .appendingPathComponent(id.description)
    }

    private func endpoint(_ endpoint: String, id: Int, from baseURL: URL) -> URL {
        character(id: id, from: baseURL)
            .appendingPathComponent(endpoint)
    }
}
