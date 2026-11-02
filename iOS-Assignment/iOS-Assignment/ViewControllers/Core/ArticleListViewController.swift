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
    private let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
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
    }

    private func setupCollectionView() {
        collectionView.register(UINib(nibName: ArticleListCell.identifier, bundle: nil),
                                forCellWithReuseIdentifier: ArticleListCell.identifier)
        collectionView.collectionViewLayout = makeListLayout()
        collectionView.dataSource = self
        collectionView.delegate = self

        refreshControl.addTarget(self, action: #selector(pullToRefresh), for: .valueChanged)
        collectionView.refreshControl = refreshControl
    }

    private func makeListLayout() -> UICollectionViewLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
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

    @objc private func pullToRefresh() {
        loadArticles()
    }

    @objc private func connectivityChanged() {
        if articleManager.isConnected {
            loadArticles()
        }
    }
}

// MARK: - UICollectionViewDataSource

extension ArticleListViewController: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        articles.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArticleListCell.identifier, for: indexPath) as! ArticleListCell
        cell.configure(with: articles[indexPath.item])
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ArticleListViewController: UICollectionViewDelegate {
}
