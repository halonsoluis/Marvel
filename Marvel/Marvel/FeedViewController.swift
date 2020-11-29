//
//  FeedViewController.swift
//  Marvel
//
//  Created by Hugo Alonso on 24/11/2020.
//
import Foundation
import UIKit
import SnapKit


class ItemCell: UITableViewCell {

    private lazy var name: UIButton = self.createNameButton()
    private lazy var heroImage: UIImageView = self.createHeroImageView()

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    private func setupUI() {
        backgroundColor = .clear
        clipsToBounds = true
        selectionStyle = .none

        addSubview(heroImage)
        addSubview(name)

        heroImage.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        name.snp.makeConstraints { make in
            make.centerY.equalToSuperview().multipliedBy(1.5)
            make.right.equalToSuperview().inset(16)
        }
    }

    func setup(using feedDataProvider: FeedDataProvider, itemAt index: Int) {
        feedDataProvider.perform(action: .setHeroImage(index: index, on: heroImage))
        name.setTitle(feedDataProvider.items[index].name, for: .normal)
    }
}

// MARK: Initialisers
extension ItemCell {
    private func createHeroImageView() -> UIImageView {
        let imageView = UIImageView()
        imageView.accessibilityIdentifier = "heroImage"
        imageView.backgroundColor = .black
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }

    private func createNameButton() -> UIButton {
        let nameLabel = UIButton()
        nameLabel.setTitleColor(.black, for: .normal)
        nameLabel.titleLabel?.adjustsFontSizeToFitWidth = false
        nameLabel.titleLabel?.autoresizesSubviews = true
        nameLabel.autoresizingMask = [UIView.AutoresizingMask.flexibleRightMargin, UIView.AutoresizingMask.flexibleTopMargin]
        nameLabel.backgroundColor = .clear
        nameLabel.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        nameLabel.accessibilityIdentifier = "name"
        nameLabel.titleLabel?.lineBreakMode = .byWordWrapping
        nameLabel.titleLabel?.numberOfLines = 0
        nameLabel.setBackgroundImage(UIImage(named: "bg-cell-title"), for: .normal)

        nameLabel.titleEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        return nameLabel
    }
}

class FeedViewController: UITableViewController {

    var feedDataProvider: FeedDataProvider?
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(feedDataProvider: FeedDataProvider) {
        self.feedDataProvider = feedDataProvider
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareTableView()

        feedDataProvider?.onItemsChangeCallback = newItemsReceived
        feedDataProvider?.perform(action: .loadFromStart)
    }

    func newItemsReceived() {
        guard let items = feedDataProvider?.items else {
            return
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    func prepareTableView() {
        tableView.allowsMultipleSelection = false
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 180
        tableView.separatorStyle = .none
        tableView.accessibilityIdentifier = "ItemsTableView"
        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")

        tableView.delegate = self
        tableView.prefetchDataSource = self

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(
            self, action:
            #selector(handleRefreshControl),
            for: .valueChanged
        )
    }

    @objc func handleRefreshControl() {
        tableView.refreshControl?.beginRefreshing()
        feedDataProvider?.perform(action: .loadFromStart)
    }
}

extension FeedViewController {
    override func numberOfSections(in tableView: UITableView) -> Int { 1 }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { feedDataProvider?.items.count ?? 0 }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let feedDataProvider = feedDataProvider,
              let cell: ItemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as? ItemCell
        else { return UITableViewCell() }

        cell.setup(using: feedDataProvider, itemAt: indexPath.row)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        feedDataProvider?.perform(action: .openItem(index: indexPath.row))
    }
}


extension FeedViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        feedDataProvider?.perform(action: .prepareForDisplay(indexes: indexPaths.map { $0.row }))
    }
}
