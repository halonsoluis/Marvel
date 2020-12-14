//
//  CharactersFeedUserAction.swift
//  Marvel
//
//  Created by Hugo Alonso on 09/12/2020.
//

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
