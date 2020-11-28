//
//  FeedViewController.swift
//  Marvel
//
//  Created by Hugo Alonso on 24/11/2020.
//
import Foundation
import UIKit



class ItemCell: UITableViewCell {

    func setup(using feedDataProvider: FeedDataProvider, itemAt index: Int) {
        if let imageField = imageView {
            feedDataProvider.perform(action: .setHeroImage(index: index, on: imageField))
        }
        if let nameField = textLabel {
            nameField.text = feedDataProvider.items[index].name
        }
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
        tableView.delegate = self
        tableView.prefetchDataSource = self

        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")

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
