import Foundation

protocol PublicationFeedDataProvider: ContentUpdatePerformer {
    var items: [BasicPublicationData] { get }

    func perform(action: CharactersDetailsUserAction)
}
