import Foundation

public struct ImageCreator {
    let url: URL
    let uniqueKey: String

    public init(url: URL, uniqueKey: String) {
        self.url = url
        self.uniqueKey = uniqueKey
    }

    public var image: Image {
        CachedImage(url: url, uniqueKey: uniqueKey)
    }
}
