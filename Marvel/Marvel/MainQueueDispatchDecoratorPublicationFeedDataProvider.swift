//
//  MainQueueDispatchDecoratorPublicationFeedDataProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 10/12/2020.
//

import Foundation

final class MainQueueDispatchDecoratorPublicationFeedDataProvider: PublicationFeedDataProvider {

    private var decoratee: PublicationFeedDataProvider

    init(_ decoratee: PublicationFeedDataProvider){
        self.decoratee = decoratee
    }

    func perform(action: CharactersDetailsUserAction) {
        DispatchQueue.global(qos: .userInitiated).async {
            self.decoratee.perform(action: action)
        }
    }

    var onItemsChangeCallback: (() -> Void)? {
        willSet {
            decoratee.onItemsChangeCallback = {
                Self.guaranteeMainThread {
                    newValue?()
                }
            }
        }
    }

    private static func guaranteeMainThread(_ work: @escaping () -> Void) {
        if Thread.isMainThread {
            work()
        } else {
            DispatchQueue.main.async {
                work()
            }
        }
    }

    var items: [BasicPublicationData] {
        decoratee.items
    }
}
