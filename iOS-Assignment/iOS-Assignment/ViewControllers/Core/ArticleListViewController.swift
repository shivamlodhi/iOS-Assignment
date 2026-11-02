//
//  ArticleListViewController.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import SwiftUI
import XCGLogger

final class ArticleListViewController: UIViewController {

    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    var articleManager: ArticleManager!
    var router: AppRouter!

    private var articles: [Article] = []
    // Articles after applying the search text
    private var visibleArticles: [Article] = []
    private var searchText = ""
    private var isGridMode = false
    private var wasConnected = true

    private let refreshControl = UIRefreshControl()
    private var stateViewController: UIHostingController<StateView>?
    private let searchController = UISearchController(searchResultsController: nil)
    private let layoutButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSearch()
        setupCollectionView()
        loadArticles()

        wasConnected = articleManager.isConnected
        NotificationCenter.default.addObserver(self, selector: #selector(connectivityChanged),
                                               name: .connectivityChanged, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // iOS 26 turns the bar dark when the dark cards scroll under it, keep it white like the design
        navigationController?.navigationBar.overrideUserInterfaceStyle = .light
    }

    private func setupNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .clear
        navigationItem.standardAppearance = appearance
        navigationItem.scrollEdgeAppearance = appearance

        // Soft shadow under the header like in the design
        let navigationBar = navigationController?.navigationBar
        navigationBar?.tintColor = .black
        navigationBar?.layer.shadowColor = UIColor.black.cgColor
        navigationBar?.layer.shadowOpacity = 0.08
        navigationBar?.layer.shadowOffset = CGSize(width: 0, height: 6)
        navigationBar?.layer.shadowRadius = 8

        // Title sits on the left, in the same row as the buttons
        let titleLabel = UILabel()
        titleLabel.text = AppStrings.articlesTitle
        titleLabel.font = AppFonts.screenTitle
        titleLabel.textColor = .black
        titleLabel.adjustsFontForContentSizeCategory = true
        let titleItem = UIBarButtonItem(customView: titleLabel)
        if #available(iOS 26.0, *) {
            titleItem.hidesSharedBackground = true
        }
        navigationItem.leftBarButtonItem = titleItem
        navigationItem.backButtonDisplayMode = .minimal

        layoutButton.setImage(AppIcons.grid, for: .normal)
        layoutButton.accessibilityLabel = AppStrings.changeLayout
        layoutButton.addTarget(self, action: #selector(layoutButtonTapped), for: .touchUpInside)

        let searchButton = UIButton(type: .system)
        searchButton.setImage(AppIcons.search, for: .normal)
        searchButton.accessibilityLabel = AppStrings.search
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)

        // Both icons in one stack so the gap between them matches the design
        let buttonStack = UIStackView(arrangedSubviews: [layoutButton, searchButton])
        buttonStack.spacing = 14
        let buttonsItem = UIBarButtonItem(customView: buttonStack)
        // Plain icons like the design, without the iOS 26 glass capsule behind them
        if #available(iOS 26.0, *) {
            buttonsItem.hidesSharedBackground = true
        }
        navigationItem.rightBarButtonItem = buttonsItem
    }

    private func setupSearch() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = AppStrings.searchPlaceholder
        searchController.searchBar.tintColor = .black
        searchController.searchBar.autocapitalizationType = .none
        // Keep the search bar at the top on iOS 26 too, instead of the bottom toolbar
        navigationItem.preferredSearchBarPlacement = .stacked
        if #available(iOS 26.0, *) {
            navigationItem.searchBarPlacementAllowsToolbarIntegration = false
        }
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

        // Grid switches to one column for accessibility text sizes
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (viewController: Self, _) in
            if viewController.isGridMode {
                viewController.collectionView.setCollectionViewLayout(viewController.makeGridLayout(), animated: false)
            }
        }
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
        let columns = traitCollection.preferredContentSizeCategory.isAccessibilityCategory ? 1 : 2
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
                self.reloadContent()
            case .cached(let articles, let error):
                log.warning("Showing cached articles: \(error.message)")
                self.articles = articles
                self.reloadContent()
                let message = error == .noInternet ? AppStrings.offlineToast : AppStrings.refreshFailedToast
                ToastHelper.showWarning(message, on: self)
            case .failure(let error):
                log.error("No articles to show: \(error.message)")
                self.articles = []
                self.visibleArticles = []
                self.collectionView.reloadData()
                self.showState(error == .noInternet ? .offline(onRetry: self.retry) : .error(error, onRetry: self.retry))
            }
        }
    }

    private func reloadContent() {
        visibleArticles = searchText.isEmpty ? articles : articles.filter { $0.matches(searchText) }
        collectionView.reloadData()

        if articles.isEmpty {
            showState(.empty(onRetry: retry))
        } else if visibleArticles.isEmpty {
            showState(.noResults(for: searchText))
        } else {
            hideState()
        }
    }

    // MARK: - State view

    private func showState(_ stateView: StateView) {
        if let stateViewController {
            stateViewController.rootView = stateView
            return
        }

        let hostingController = UIHostingController(rootView: stateView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
        stateViewController = hostingController
    }

    private func hideState() {
        stateViewController?.willMove(toParent: nil)
        stateViewController?.view.removeFromSuperview()
        stateViewController?.removeFromParent()
        stateViewController = nil
    }

    private func retry() {
        hideState()
        loadArticles()
    }

    // MARK: - Actions

    @objc private func pullToRefresh() {
        loadArticles()
    }

    @objc private func connectivityChanged() {
        // Reachability also posts when it starts, only react to a real change
        let isConnected = articleManager.isConnected
        guard isConnected != wasConnected else { return }
        wasConnected = isConnected

        if isConnected {
            loadArticles()
        } else if !articles.isEmpty {
            // With no articles the offline screen already says it
            ToastHelper.showWarning(AppStrings.offlineToast, on: self)
        }
    }

    @objc private func layoutButtonTapped() {
        isGridMode.toggle()
        layoutButton.setImage(isGridMode ? AppIcons.list : AppIcons.grid, for: .normal)

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
        cell.onReadMore = { [weak self, weak cell] in
            guard let self else { return }
            self.router.showDetail(for: article, from: self, sourceView: cell)
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ArticleListViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        router.showDetail(for: visibleArticles[indexPath.item], from: self,
                          sourceView: collectionView.cellForItem(at: indexPath))
    }
}

// MARK: - Search

extension ArticleListViewController: UISearchResultsUpdating, UISearchControllerDelegate {

    func updateSearchResults(for searchController: UISearchController) {
        searchText = searchController.searchBar.text?.trimmingCharacters(in: .whitespaces) ?? ""
        reloadContent()
    }

    func didPresentSearchController(_ searchController: UISearchController) {
        DispatchQueue.main.async {
            searchController.searchBar.becomeFirstResponder()
        }
    }

    func didDismissSearchController(_ searchController: UISearchController) {
        navigationItem.searchController = nil
    }
}
