//
//  PublicationFeedDataProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 09/12/2020.
//

import Foundation

protocol PublicationFeedDataProvider: ContentUpdatePerformer {
    var items: [BasicPublicationData] { get }

    func perform(action: CharactersDetailsUserAction)
}
