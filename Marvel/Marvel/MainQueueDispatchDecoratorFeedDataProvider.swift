//
//  MainQueueDispatchDecoratorFeedDataProvider.swift
//  Marvel
//
//  Created by Hugo Alonso on 06/12/2020.
//

import Foundation

final class MainQueueDispatchDecoratorFeedDataProvider: FeedDataProvider {
    private var decoratee: FeedDataProvider

    init(_ decoratee: FeedDataProvider){
        self.decoratee = decoratee
    }

    func perform(action: CharactersFeedUserAction) {
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

    var items: [BasicCharacterData] {
        decoratee.items
    }
}
