//
//  PublicationFeedDataProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 09/12/2020.
//

import Foundation

protocol PublicationFeedDataProvider: class {
    var items: [BasicPublicationData] { get }
    var onItemsChangeCallback: (() -> Void)? { get set }

    func perform(action: CharactersDetailsUserAction)
}
