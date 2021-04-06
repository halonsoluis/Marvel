//
//  PublicationCollection.swift
//  Marvel
//
//  Created by Hugo Alonso on 08/12/2020.
//

import Foundation
import UIKit

typealias DataSource = UICollectionViewDiffableDataSource<Int, BasicPublicationData>
typealias LoadImageHandlerResult = (Error?) -> Void
typealias LoadImageHandlerType = (ImageFormula, UIImageView, @escaping LoadImageHandlerResult) -> Void

final class PublicationCollection: UIViewController, UICollectionViewDelegate {
    private lazy var sectionName: UILabel = createSection()
    private lazy var collection: UICollectionView = createCollection()
    private lazy var dataSource: DataSource = makeDataSource()

    private static let reuseIdentifier = "PublicationCell"
    private let characterId: Int
    private let section: String
    private let loadImageHandler: LoadImageHandlerType
    private let feedDataProvider: PublicationFeedDataProvider

    init(characterId: Int,
         section: String,
         loadImageHandler: @escaping LoadImageHandlerType,
         feedDataProvider: PublicationFeedDataProvider) {
        self.characterId = characterId
        self.section = section
        self.loadImageHandler = loadImageHandler
        self.feedDataProvider = feedDataProvider

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        collection.dataSource = dataSource
        updateDataSource(animated: false)
        
        feedDataProvider.onItemsChangeCallback = newItemsReceived
        feedDataProvider.perform(action: .loadFromStart(characterId: characterId, type: section))
    }

    func newItemsReceived() {
        //Update data
        view.isHidden = feedDataProvider.items.isEmpty
        updateDataSource(animated: true)
    }

    private func updateDataSource(animated: Bool = false) {

        var snapshot = NSDiffableDataSourceSnapshot<Int, BasicPublicationData>()
        snapshot.appendSections([0])
        snapshot.appendItems(feedDataProvider.items, toSection: 0)

        dataSource.apply(snapshot, animatingDifferences: animated)
    }

    func setupUI() {
        view.backgroundColor = .black

        view.addSubview(sectionName)
        view.addSubview(collection)

        sectionName.translatesAutoresizingMaskIntoConstraints = false
        collection.translatesAutoresizingMaskIntoConstraints = false

        sectionName.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        collection.snp.makeConstraints { make in
            make.top.equalTo(sectionName.snp.bottom).offset(8)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(4)
            make.height.equalTo(PublicationCell.cellSize)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected \(indexPath.row)")
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let itemCount = feedDataProvider.items.count

        guard itemCount > 0 else { return }

        if (indexPath.row == itemCount - 1) {
            feedDataProvider.perform(action: .loadMore(characterId: characterId, type: section))
        }
    }
}

// MARK: Initialisers
extension PublicationCollection {
    private func createSection() -> UILabel {
        let sectionName = UILabel()

        sectionName.textColor = .red
        sectionName.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        sectionName.text = section.capitalized
        sectionName.textAlignment = .justified

        return sectionName
    }

    private func createCollection() -> UICollectionView {
        let collection = UICollectionView(
            frame: CGRect(
                origin: CGPoint(x: 0, y: 0),
                size: CGSize(
                    width: view.bounds.width,
                    height: 400
                )
            ),
            collectionViewLayout: createBasicListLayout()
        )

        collection.allowsMultipleSelection = false
        collection.register(PublicationCell.self, forCellWithReuseIdentifier: "PublicationCell")
        collection.delegate = self

        return collection
    }

    func createBasicListLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(0.9))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .continuous

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

}

private extension PublicationCollection {
    func makeDataSource() -> DataSource {
        DataSource(
            collectionView: collection,
            cellProvider: { [weak self] (collection, indexPath, crossReference) -> UICollectionViewCell? in

                guard let cell = collection.dequeueReusableCell(
                        withReuseIdentifier: Self.reuseIdentifier,
                        for: indexPath
                ) as? PublicationCell else { return nil }

                cell.nameLabel.text = crossReference.title
                cell.image.image = nil

                if let feedDataProvider = self?.feedDataProvider {
                    feedDataProvider.perform(
                        action: .setHeroImage(index: indexPath.row, on: cell.image)
                    )
                }
                return cell
            }
        )
    }
}
