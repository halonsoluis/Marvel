import Foundation

protocol FeedDataProvider: ContentUpdatePerformer {
    var items: [BasicCharacterData] { get }

    func perform(action: CharactersFeedUserAction)
}
