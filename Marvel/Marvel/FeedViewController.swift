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

    enum Section: CaseIterable {
        case main
    }
    private let cellReuseIdentifier = "ItemCell"
    private lazy var tableView: UITableView = UITableView()
    private lazy var dataSource: UITableViewDiffableDataSource<Section, BasicCharacterData> = makeDataSource()

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

        prepareTableView()
        updateDataSource()

        feedDataProvider?.onItemsChangeCallback = newItemsReceived

        feedDataProvider?.perform(action: .loadFromStart)
    }

    func newItemsReceived() {
        DispatchQueue.main.async {
            self.updateDataSource()
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    func updateDataSource() {
        guard let feedDataProvider = feedDataProvider else { return }

        var snapshot = NSDiffableDataSourceSnapshot<Section, BasicCharacterData>()
        snapshot.appendSections([Section.main])
        snapshot.appendItems(feedDataProvider.items, toSection: .main)

        self.dataSource.apply(snapshot, animatingDifferences: true)
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
        tableView.refreshControl?.addTarget(self, action:  #selector(handleRefreshControl), for: .valueChanged)
        tableView.dataSource = dataSource
    }

    @objc func handleRefreshControl() {
        tableView.refreshControl?.beginRefreshing()
        feedDataProvider?.perform(action: .loadFromStart)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let tableViewHeight = tableView.bounds.height
        let tableViewContentHeight = tableView.contentSize.height
        let tableViewContentBottomInset = tableView.contentInset.bottom
        let currentVerticalPosition = scrollView.contentOffset.y + tableViewHeight - tableViewContentBottomInset

        let reloadDistance = tableViewHeight * 2

        if currentVerticalPosition > (tableViewContentHeight - reloadDistance) {
            feedDataProvider?.perform(action: .loadMore)
        }
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

private extension FeedViewController {
    func makeDataSource() -> UITableViewDiffableDataSource<Section, BasicCharacterData> {
        let reuseIdentifier = cellReuseIdentifier

        return UITableViewDiffableDataSource(
            tableView: tableView,
            cellProvider: { [weak self] tableView, indexPath, character in
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: reuseIdentifier,
                    for: indexPath
                ) as? ItemCell

                if let feedDataProvider = self?.feedDataProvider {
                    cell?.setup(using: feedDataProvider, itemAt: indexPath.row)
                }
                return cell
            }
        )
    }
}
