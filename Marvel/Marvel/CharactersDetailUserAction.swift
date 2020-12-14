//
//  CharactersDetailUserAction.swift
//  Marvel
//
//  Created by Hugo Alonso on 10/12/2020.
//

import Foundation
import UIKit

enum CharactersDetailsUserAction {
    case loadFromStart(characterId: Int, type: String)
    case loadMore(characterId: Int, type: String)
    case prepareForDisplay(indexes: [Int])
    case setHeroImage(index: Int, on: UIImageView)
}
