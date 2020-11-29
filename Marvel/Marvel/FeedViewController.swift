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

    private lazy var searchBar: UISearchBar = createSearchBar()
    private lazy var tableView: UITableView = createTableView()

    private var feedDataProvider: FeedDataProvider?

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    init(feedDataProvider: FeedDataProvider) {
        self.feedDataProvider = feedDataProvider
        super.init(nibName: nil, bundle: nil)
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
        navigationController?.navigationBar.barTintColor = .black

        navigationItem.titleView = UIImageView(image: UIImage(named: "icn-nav-marvel"))

        view.addSubview(searchBar)
        view.addSubview(tableView)

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
        }

        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.right.left.bottom.equalToSuperview()
        }
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

    private func createSearchBar() -> UISearchBar {
        let searchBar = UISearchBar()
        searchBar.barTintColor = .black
        searchBar.searchBarStyle = .default
        searchBar.placeholder = "Try introducing a name here"
        searchBar.autocapitalizationType = .none
        searchBar.searchTextField.textColor = .black

        searchBar.searchTextField.addTarget(self, action:  #selector(updateSearchCriteria), for: .editingChanged)
        return searchBar
    }

    @objc func handleRefreshControl() {
        tableView.refreshControl?.beginRefreshing()
        feedDataProvider?.perform(action: .loadFromStart)
    }

    @objc func updateSearchCriteria() {
        feedDataProvider?.perform(action: .search(name: searchBar.text))
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
