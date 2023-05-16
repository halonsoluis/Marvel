import Foundation
import UIKit

enum CharactersFeedUserAction {
    case loadFromStart
    case loadMore
    case openItem(index: Int)
    case search(name: String?)
    case prepareForDisplay(indexes: [Int])
    case setHeroImage(index: Int, on: UIImageView)
}
