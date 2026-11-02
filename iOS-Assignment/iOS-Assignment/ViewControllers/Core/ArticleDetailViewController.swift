//
//  ArticleDetailViewController.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import SafariServices

final class ArticleDetailViewController: UIViewController {

    @IBOutlet private weak var scrollView: UIScrollView!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var clockImageView: UIImageView!
    @IBOutlet private weak var timeLabel: UILabel!
    @IBOutlet private weak var imageContainerView: UIView!
    @IBOutlet private weak var articleImageView: ArticleImageView!
    @IBOutlet private weak var bodyLabel: UILabel!
    @IBOutlet private weak var readFullArticleButton: UIButton!
    @IBOutlet private weak var titleTopConstraint: NSLayoutConstraint!

    var article: Article!
    var favoritesManager: FavoritesManager!

    private lazy var favoriteButton = UIBarButtonItem(image: nil, style: .plain,
                                                      target: self, action: #selector(favoriteTapped))

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupViews()
        showArticle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.layer.shadowOpacity = 0
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        // Header runs behind the navigation bar, so push the title below it
        titleTopConstraint.constant = view.safeAreaInsets.top + 16
    }

    private func setupNavigationBar() {
        title = "Article"

        let transparent = UINavigationBarAppearance()
        transparent.configureWithTransparentBackground()
        transparent.titleTextAttributes = [.foregroundColor: UIColor.white, .font: AppFonts.navigationTitle]
        transparent.setBackIndicatorImage(AppIcons.back, transitionMaskImage: AppIcons.back)

        let scrolled = UINavigationBarAppearance()
        scrolled.configureWithOpaqueBackground()
        scrolled.backgroundColor = AppColors.cardBackground
        scrolled.shadowColor = .clear
        scrolled.titleTextAttributes = transparent.titleTextAttributes
        scrolled.setBackIndicatorImage(AppIcons.back, transitionMaskImage: AppIcons.back)

        navigationItem.scrollEdgeAppearance = transparent
        navigationItem.standardAppearance = scrolled
        navigationItem.rightBarButtonItem = favoriteButton
        updateFavoriteButton()
    }

    private func setupViews() {
        view.backgroundColor = AppColors.detailBackground
        headerView.backgroundColor = AppColors.cardBackground

        titleLabel.font = AppFonts.detailTitle
        titleLabel.textColor = .white
        titleLabel.adjustsFontForContentSizeCategory = true

        timeLabel.font = AppFonts.date
        timeLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        timeLabel.adjustsFontForContentSizeCategory = true
        clockImageView.image = AppIcons.clock
        clockImageView.tintColor = UIColor.white.withAlphaComponent(0.7)

        imageContainerView.layer.shadowColor = UIColor.black.cgColor
        imageContainerView.layer.shadowOpacity = 0.25
        imageContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageContainerView.layer.shadowRadius = 8

        bodyLabel.textColor = AppColors.bodyText
        bodyLabel.adjustsFontForContentSizeCategory = true

        var config = UIButton.Configuration.filled()
        config.title = "Read Full Article"
        config.image = UIImage(systemName: "safari")
        config.imagePlacement = .trailing
        config.imagePadding = 10
        config.baseBackgroundColor = AppColors.primaryBlue
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var attributes = attributes
            attributes.font = AppFonts.button
            return attributes
        }
        readFullArticleButton.configuration = config
    }

    private func showArticle() {
        titleLabel.text = article.title ?? "Untitled article"

        timeLabel.text = DateHelper.timeAgo(from: article.publishedAt)
        clockImageView.isHidden = timeLabel.text == nil

        articleImageView.setImage(with: article.imageURL)

        let body = article.content ?? article.description ?? "No details available for this article."
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        bodyLabel.attributedText = NSAttributedString(string: body, attributes: [
            .font: AppFonts.body,
            .paragraphStyle: paragraphStyle
        ])

        // Some articles have a missing or broken link
        readFullArticleButton.isHidden = article.articleURL == nil
    }

    private func updateFavoriteButton() {
        favoriteButton.image = favoritesManager.isFavorite(article) ? AppIcons.favoriteFilled : AppIcons.favorite
    }

    // MARK: - Actions

    @objc private func favoriteTapped() {
        favoritesManager.toggleFavorite(article)
        updateFavoriteButton()
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    @IBAction private func readFullArticleTapped() {
        guard let url = article.articleURL else { return }
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.preferredControlTintColor = AppColors.primaryBlue
        present(safariViewController, animated: true)
    }
}
