//
//  PublicationCollection.swift
//  Marvel
//
//  Created by Hugo Alonso on 08/12/2020.
//

import Foundation
import UIKit
import CharactersAPI

final class PublicationCollection: UIViewController, UICollectionViewDataSource {
    lazy var section: UILabel = createSection()
    lazy var collection: UICollectionView = createCollection()

    let sectionName: String
    let loadImageHandler: (URL, String, UIImageView, @escaping ((Error?) -> Void)) -> Void
    let feedDataProvider: PublicationFeedDataProvider

    init(sectionName: String, loadImageHandler: @escaping (URL, String, UIImageView, @escaping ((Error?) -> Void)) -> Void, feedDataProvider: PublicationFeedDataProvider) {
        self.sectionName = sectionName
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
        feedDataProvider.onItemsChangeCallback = newItemsReceived
        feedDataProvider.perform(action: .loadFromStart)
    }

    func newItemsReceived() {
        //Update data
        collection.reloadData()
    }

    func setupUI() {
        view.backgroundColor = .black

        view.addSubview(section)
        view.addSubview(collection)

        section.translatesAutoresizingMaskIntoConstraints = false
        collection.translatesAutoresizingMaskIntoConstraints = false

        section.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(4)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
        }

        collection.snp.makeConstraints { make in
            make.top.equalTo(section.snp.bottom).offset(8)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(4)
            make.height.equalTo(PublicationCell.cellSize)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PublicationCell", for: indexPath) as? PublicationCell
        else { return UICollectionViewCell()}

        let crossReference = feedDataProvider.items[indexPath.row]

        cell.nameLabel.text = crossReference.title

        cell.image.image = nil
        feedDataProvider.perform(action: .setHeroImage(index: indexPath.row, on: cell.image))

        return cell
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return feedDataProvider.items.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("selected \(indexPath.row)")
    }
}

// MARK: Initialisers
extension PublicationCollection {
    private func createSection() -> UILabel {
        let section = UILabel()

        section.textColor = .red
        section.font = UIFont.boldSystemFont(ofSize: 17)
        section.text = sectionName
        section.textAlignment = .justified

        return section
    }

    private func createCollection() -> UICollectionView {
        let collection = UICollectionView(
            frame: CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: view.bounds.width, height: 400)),
            collectionViewLayout: createBasicListLayout()
        )
        collection.allowsMultipleSelection = false
        collection.register(PublicationCell.self, forCellWithReuseIdentifier: "PublicationCell")
        collection.dataSource = self

        return collection
    }

    func createBasicListLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.3), heightDimension: .fractionalHeight(0.9))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)

        section.orthogonalScrollingBehavior = .continuousGroupLeadingBoundary

        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }

}
