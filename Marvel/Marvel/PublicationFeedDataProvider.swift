//
//  PublicationFeedDataProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 09/12/2020.
//

import Foundation
import CharactersAPI

protocol PublicationFeedDataProvider: class {
    var items: [MarvelPublication] { get }
    var onItemsChangeCallback: (() -> Void)? { get set }

    func perform(action: CharactersFeedUserAction)
}
