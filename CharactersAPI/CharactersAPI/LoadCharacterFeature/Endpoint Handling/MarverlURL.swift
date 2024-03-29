import Foundation

struct MarvelURL {
    let baseURL: URL
    let config: MarvelAPIConfig
    private let hashResolver: (String...) -> String
    private let timeProvider: () -> Date

    init(_ baseURL: URL, config: MarvelAPIConfig, hashResolver: @escaping (String...) -> String, timeProvider: @escaping () -> Date) {
        self.baseURL = baseURL
        self.config = config
        self.hashResolver = hashResolver
        self.timeProvider = timeProvider
    }

    func url(route: RouteComposer, nameStartingWith: String? = nil, for page: Int = 0) -> URL? {
        guard var components = URLComponents(url: route.url(from: baseURL), resolvingAgainstBaseURL: false) else {
            return nil
        }

        var params: [[String: String]] = [
            securityParams(at: timeProvider(), using: hashResolver),
            pagination(for: page),
            filter(by: nameStartingWith),
        ]

        if route == .characters {
            params.append(sortedBy())
        }
        components.queryItems = params.joined().map(URLQueryItem.init)
        return components.url
    }

    private func securityParams(at time: Date, using hashResolver: (String...) -> String) -> [String: String] {
        let timestamp = time.timeIntervalSinceReferenceDate.description
        return [
            "apikey": config.publicAPIKey,
            "hash": hashResolver(timestamp, config.privateAPIKey, config.publicAPIKey),
            "ts": timestamp,
        ]
    }

    private func sortedBy() -> [String: String] {
        [
            "orderBy": "name",
        ]
    }

    private func pagination(for page: Int = 0) -> [String: String] {
        [
            "limit": (config.itemsPerPage).description,
            "offset": (page * config.itemsPerPage).description,
        ]
    }

    private func filter(by nameStartingWith: String?) -> [String: String] {
        guard let filter = nameStartingWith else {
            return [:]
        }
        return [
            "nameStartsWith": filter,
        ]
    }
}
