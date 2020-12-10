//
//  CharactersDetailUserAction.swift
//  Marvel
//
//  Created by Hugo Alonso on 10/12/2020.
//

import Foundation
import CharactersAPI
import UIKit

enum CharactersDetailsUserAction {
    case loadFromStart(characterId: Int, type: MarvelPublication.Kind)
    case loadMore(characterId: Int, type: MarvelPublication.Kind)
    case prepareForDisplay(indexes: [Int])
    case setHeroImage(index: Int, on: UIImageView)
}
