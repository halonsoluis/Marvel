import Foundation

struct Image: Codable {
    let path: String?
    let `extension`: String?
}

extension Image {
    var resolvedURL: URL? {
        guard let url = path, let type = `extension` else {
            return nil
        }
        return URL(string: "\(url.replacingOccurrences(of: "http:", with: "https:")).\(type)")
    }
}
