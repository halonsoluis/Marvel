//
//  FeedDataProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 09/12/2020.
//

import Foundation

protocol FeedDataProvider: ContentUpdatePerformer {
    var items: [BasicCharacterData] { get }

    func perform(action: CharactersFeedUserAction)
}
