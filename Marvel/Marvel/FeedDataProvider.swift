//
//  FeedDataProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 09/12/2020.
//

import Foundation

protocol FeedDataProvider: class {
    var items: [BasicCharacterData] { get }
    var onItemsChangeCallback: (() -> Void)? { get set }

    func perform(action: CharactersFeedUserAction)
}
