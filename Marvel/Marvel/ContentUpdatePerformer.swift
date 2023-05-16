import Foundation

protocol ContentUpdatePerformer {
    var onItemsChangeCallback: (() -> Void)? { get set }
}
