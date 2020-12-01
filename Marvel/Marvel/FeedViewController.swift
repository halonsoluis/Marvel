//
//  FeedViewController.swift
//  Marvel
//
//  Created by Hugo Alonso on 24/11/2020.
//
import Foundation
import UIKit
import SnapKit

class FeedViewController: UIViewController {

    private lazy var tableView: UITableView = createTableView()

    private var feedDataProvider: FeedDataProvider?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(feedDataProvider: FeedDataProvider) {
        super.init(nibName: nil, bundle: nil)

        self.feedDataProvider = feedDataProvider
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        layoutUI()

        feedDataProvider?.onItemsChangeCallback = newItemsReceived
        feedDataProvider?.perform(action: .loadFromStart)
    }

    func newItemsReceived() {
        guard feedDataProvider?.items != nil else {
            return
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    func layoutUI() {
        view.backgroundColor = .black

        navigationController?.navigationBar.tintColor = .red
        navigationController?.navigationBar.barStyle = .black

        navigationItem.titleView = UIImageView(image: UIImage(named: "icn-nav-marvel"))
        navigationItem.hidesSearchBarWhenScrolling = true
        navigationItem.searchController = createSearchController()

        view.addSubview(tableView)

        tableView.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.right.left.bottom.equalToSuperview()
        }
    }

    func createSearchController() -> UISearchController {
        let search = UISearchController(searchResultsController: nil)

        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false

        search.searchBar.placeholder = "Try introducing a name here"
        search.searchBar.autocapitalizationType = .none
        search.searchBar.searchTextField.textColor = .white

        return search
    }

    func createTableView() -> UITableView {
        let tableView = UITableView()
        tableView.allowsMultipleSelection = false
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 180
        tableView.separatorStyle = .none
        tableView.accessibilityIdentifier = "ItemsTableView"
        tableView.register(ItemCell.self, forCellReuseIdentifier: "ItemCell")

        tableView.delegate = self
        tableView.dataSource = self
        tableView.prefetchDataSource = self

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action:  #selector(handleRefreshControl), for: .valueChanged)
        return tableView
    }

    @objc func handleRefreshControl() {
        tableView.refreshControl?.beginRefreshing()
        feedDataProvider?.perform(action: .loadFromStart)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        if position > (tableView.contentSize.height - 100 - scrollView.frame.size.height) {
            feedDataProvider?.perform(action: .loadMore)
        }
    }

}

extension FeedViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        feedDataProvider?.items.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let feedDataProvider = feedDataProvider,
              let cell: ItemCell = tableView.dequeueReusableCell(withIdentifier: "ItemCell") as? ItemCell
        else { return UITableViewCell() }

        cell.setup(using: feedDataProvider, itemAt: indexPath.row)
        return cell
    }
}

extension FeedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        feedDataProvider?.perform(action: .openItem(index: indexPath.row))
    }
}


extension FeedViewController: UITableViewDataSourcePrefetching {
    func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        feedDataProvider?.perform(action: .prepareForDisplay(indexes: indexPaths.map { $0.row }))
    }
}

extension FeedViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        feedDataProvider?.perform(action: .search(name: searchController.searchBar.text))
    }
}
