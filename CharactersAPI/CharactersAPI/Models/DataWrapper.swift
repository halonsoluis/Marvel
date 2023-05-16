import Foundation

struct DataWrapper<T: Codable>: Codable {
    let code: Int?
    let status: String?
    let data: DataContainer<T>?
}
