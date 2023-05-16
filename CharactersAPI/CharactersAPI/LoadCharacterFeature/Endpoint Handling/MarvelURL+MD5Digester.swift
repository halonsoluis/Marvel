import CommonCrypto
import Foundation

extension MarvelURL {
    enum MD5Digester {
        static func createHash(_ values: String...) -> String {
            digest(values.joined())
        }

        // return MD5 digest of string provided
        private static func digest(_ string: String) -> String {
            guard let data = string.data(using: String.Encoding.utf8) else {
                return ""
            }

            var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))

            CC_MD5((data as NSData).bytes, CC_LONG(data.count), &digest)

            return (0 ..< Int(CC_MD5_DIGEST_LENGTH)).reduce("") { $0 + String(format: "%02x", digest[$1]) }
        }
    }
}
