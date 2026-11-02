//
//  ArticleListViewController.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import XCGLogger

final class ArticleListViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    var articleManager: ArticleManager!

    private var articles: [Article] = []
    private var searchText = ""
    private var isGridMode = false

    private let refreshControl = UIRefreshControl()
    private let searchController = UISearchController(searchResultsController: nil)
    private lazy var layoutButton = UIBarButtonItem(image: AppIcons.grid, style: .plain,
                                                    target: self, action: #selector(layoutButtonTapped))

    // Articles after applying the search text
    private var visibleArticles: [Article] {
        guard !searchText.isEmpty else { return articles }
        return articles.filter {
            ($0.title ?? "").localizedCaseInsensitiveContains(searchText) ||
            ($0.description ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearch()
        setupCollectionView()
        loadArticles()

        NotificationCenter.default.addObserver(self, selector: #selector(connectivityChanged),
                                               name: .connectivityChanged, object: nil)
    }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [.font: AppFonts.screenTitle]

        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationController?.navigationBar.directionalLayoutMargins.leading = 20
        navigationController?.navigationBar.tintColor = .label

        let searchButton = UIBarButtonItem(image: AppIcons.search, style: .plain,
                                           target: self, action: #selector(searchButtonTapped))
        navigationItem.rightBarButtonItems = [searchButton, layoutButton]
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search articles"
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: ArticleListCell.identifier, bundle: nil),
                                forCellWithReuseIdentifier: ArticleListCell.identifier)
        collectionView.register(UINib(nibName: ArticleGridCell.identifier, bundle: nil),
                                forCellWithReuseIdentifier: ArticleGridCell.identifier)
        collectionView.collectionViewLayout = makeListLayout()
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.keyboardDismissMode = .onDrag

        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    // MARK: - Layouts

    private func makeListLayout() -> UICollectionViewLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8)
        return UICollectionViewCompositionalLayout(section: section)
    }

    private func makeGridLayout() -> UICollectionViewLayout {
        let columns = 2
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1 / CGFloat(columns)),
                                              heightDimension: .estimated(160))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(160))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, repeatingSubitem: item, count: columns)
        group.interItemSpacing = .fixed(10)

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 10
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8)
        return UICollectionViewCompositionalLayout(section: section)
    }

    // MARK: - Loading

    private func loadArticles() {
        if articles.isEmpty && !refreshControl.isRefreshing {
            activityIndicator.startAnimating()
        }

        articleManager.fetchArticles { [weak self] result in
            guard let self else { return }
            self.activityIndicator.stopAnimating()
            self.refreshControl.endRefreshing()

            switch result {
            case .fresh(let articles):
                self.articles = articles
            case .cached(let articles, let error):
                log.warning("Showing cached articles: \(error.message)")
                self.articles = articles
            case .failure(let error):
                log.error("No articles to show: \(error.message)")
            }
            self.collectionView.reloadData()
        }
    }

    // MARK: - Actions

    @objc private func pullToRefresh() {
        loadArticles()
    }

    @objc private func connectivityChanged() {
        if articleManager.isConnected {
            loadArticles()
        }
    }

    @objc private func layoutButtonTapped() {
        isGridMode.toggle()
        layoutButton.image = isGridMode ? AppIcons.list : AppIcons.grid

        UIView.transition(with: collectionView, duration: 0.25, options: .transitionCrossDissolve) {
            self.collectionView.setCollectionViewLayout(self.isGridMode ? self.makeGridLayout() : self.makeListLayout(),
                                                        animated: false)
            self.collectionView.reloadData()
        }
    }

    // The search bar is only shown while searching, like in the design
    @objc private func searchButtonTapped() {
        navigationItem.searchController = searchController
        DispatchQueue.main.async {
            self.searchController.isActive = true
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ArticleListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        visibleArticles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let article = visibleArticles[indexPath.item]

        if isGridMode {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleGridCell.identifier, for: indexPath) as! ArticleGridCell
            cell.configure(with: article)
            return cell
        }

        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleListCell.identifier, for: indexPath) as! ArticleListCell
        cell.configure(with: article)
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ArticleListViewController: UICollectionViewDelegate {
}

// MARK: - Search

extension ArticleListViewController: UISearchResultsUpdating, UISearchControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        collectionView.reloadData()
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.becomeFirstResponder()
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        navigationItem.searchController = nil
    }
}
