//
//  ArticleDetailViewController.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import UIKit
import SafariServices

final class ArticleDetailViewController: UIViewController {

    static let identifier = "ArticleDetailViewController"

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

    private let article: Article
    private let favoritesManager: FavoritesManager

    // Own top bar instead of the navigation bar, so it moves with the screen during the card animation
    private let topBarView = UIView()
    private let topBarTitleLabel = UILabel()
    private let backButton = UIButton(type: .system)
    private var backButtonGlassView: UIVisualEffectView?
    private let favoriteButton = UIButton(type: .system)
    private var topBarHeightConstraint: NSLayoutConstraint!
    private var topBarCenterConstraint: NSLayoutConstraint!

    init?(coder: NSCoder, article: Article, favoritesManager: FavoritesManager) {
        self.article = article
        self.favoritesManager = favoritesManager
        super.init(coder: coder)
    }

    required init?(coder: NSCoder) {
        fatalError("Use init(coder:article:favoritesManager:)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTopBar()
        setupViews()
        showArticle()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        updateBackButton()
    }

    // Also called when the iPad window shrinks and the detail moves onto the list's stack
    override func didMove(toParent parent: UIViewController?) {
        super.didMove(toParent: parent)
        if navigationController?.topViewController == self {
            hideNavigationBar()
        }
        updateBackButton()
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // The top bar covers the same area as the hidden navigation bar. The safe area can't be used
        // for this, it stops counting the navigation bar once it is faded out
        let barFrame = navigationController?.navigationBar.frame ?? .zero
        topBarHeightConstraint.constant = barFrame.maxY
        // Bar buttons sit in the top 44pt of the bar, like the system puts them
        topBarCenterConstraint.constant = barFrame.minY + AppMetrics.barButtonSize / 2
        // Header runs behind the top bar, so push the title below it
        titleTopConstraint.constant = barFrame.maxY + AppMetrics.detailTitleTopSpacing
    }

    // The navigation bar stays in place for the layout and status bar, it is only faded out
    private func hideNavigationBar() {
        setNavigationBarStyle(.dark, alpha: 0)
    }

    private func setupTopBar() {
        navigationItem.hidesBackButton = true
        topBarView.backgroundColor = AppColors.cardBackground
        topBarView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBarView)

        topBarTitleLabel.text = AppStrings.articleTitle
        topBarTitleLabel.font = AppFonts.navigationTitle
        topBarTitleLabel.textColor = .white
        topBarTitleLabel.accessibilityTraits = .header

        favoriteButton.tintColor = .white
        favoriteButton.imageView?.contentMode = .scaleAspectFit
        favoriteButton.contentHorizontalAlignment = .fill
        favoriteButton.contentVerticalAlignment = .fill
        favoriteButton.addTarget(self, action: #selector(favoriteTapped), for: .touchUpInside)
        // Favourites are saved by link, so articles without one can't be saved
        favoriteButton.isHidden = article.url == nil
        updateFavoriteButton()

        for subview in [topBarTitleLabel, backButton, favoriteButton] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            topBarView.addSubview(subview)
        }
        topBarHeightConstraint = topBarView.heightAnchor.constraint(equalToConstant: 0)
        topBarCenterConstraint = topBarTitleLabel.centerYAnchor.constraint(equalTo: view.topAnchor)
        let side = AppMetrics.detailBarSideInset
        NSLayoutConstraint.activate([
            topBarView.topAnchor.constraint(equalTo: view.topAnchor),
            topBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            topBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            topBarHeightConstraint,

            topBarCenterConstraint,
            topBarTitleLabel.centerXAnchor.constraint(equalTo: topBarView.centerXAnchor),

            backButton.leadingAnchor.constraint(equalTo: topBarView.leadingAnchor, constant: side),
            backButton.centerYAnchor.constraint(equalTo: topBarTitleLabel.centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: AppMetrics.barButtonSize),
            backButton.heightAnchor.constraint(equalToConstant: AppMetrics.barButtonSize),

            favoriteButton.trailingAnchor.constraint(equalTo: topBarView.trailingAnchor, constant: -side),
            favoriteButton.centerYAnchor.constraint(equalTo: topBarTitleLabel.centerYAnchor),
            favoriteButton.widthAnchor.constraint(equalToConstant: AppMetrics.favoriteIconSize.width),
            favoriteButton.heightAnchor.constraint(equalToConstant: AppMetrics.favoriteIconSize.height)
        ])
        setupBackButton()
    }

    // iPad shows the detail as the root of its column, so there is nothing to go back to
    private func updateBackButton() {
        backButton.isHidden = navigationController?.viewControllers.first == self
        backButtonGlassView?.isHidden = backButton.isHidden
    }

    // Round back button from the design
    private func setupBackButton() {
        backButton.setImage(AppIcons.back, for: .normal)
        backButton.tintColor = .white
        backButton.accessibilityLabel = AppStrings.back
        backButton.layer.cornerRadius = AppMetrics.barButtonSize / 2

        // Liquid Glass on iOS 26, plain see-through circle on older versions. The glass sits behind
        // the button, inside it the glass would cover the arrow
        if #available(iOS 26.0, *) {
            let glass = UIGlassEffect()
            glass.tintColor = AppColors.backButtonGlass
            let glassView = UIVisualEffectView(effect: glass)
            glassView.isUserInteractionEnabled = false
            glassView.cornerConfiguration = .capsule()
            glassView.translatesAutoresizingMaskIntoConstraints = false
            topBarView.insertSubview(glassView, belowSubview: backButton)
            NSLayoutConstraint.activate([
                glassView.leadingAnchor.constraint(equalTo: backButton.leadingAnchor),
                glassView.trailingAnchor.constraint(equalTo: backButton.trailingAnchor),
                glassView.topAnchor.constraint(equalTo: backButton.topAnchor),
                glassView.bottomAnchor.constraint(equalTo: backButton.bottomAnchor)
            ])
            backButtonGlassView = glassView
        } else {
            backButton.backgroundColor = AppColors.backButtonBackground
        }
        backButton.addTarget(self, action: #selector(backTapped), for: .touchUpInside)
    }

    private func setupViews() {
        view.backgroundColor = AppColors.detailBackground
        // iOS 26 darkens content under the bar, the design header is a flat colour
        if #available(iOS 26.0, *) {
            scrollView.topEdgeEffect.isHidden = true
        }
        headerView.backgroundColor = AppColors.cardBackground

        titleLabel.font = AppFonts.detailTitle
        titleLabel.textColor = .white
        titleLabel.adjustsFontForContentSizeCategory = true

        timeLabel.font = AppFonts.time
        timeLabel.textColor = AppColors.detailMetaText
        timeLabel.adjustsFontForContentSizeCategory = true
        clockImageView.image = AppIcons.clock
        clockImageView.tintColor = AppColors.detailMetaText

        imageContainerView.layer.shadowColor = UIColor.black.cgColor
        imageContainerView.layer.shadowOpacity = 0.25
        imageContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        imageContainerView.layer.shadowRadius = 8

        bodyLabel.font = AppFonts.body
        bodyLabel.textColor = AppColors.bodyText
        bodyLabel.adjustsFontForContentSizeCategory = true

        readFullArticleButton.configuration = .primary(title: AppStrings.readFullArticle, image: AppIcons.safari, imagePadding: 10)
    }

    private func showArticle() {
        titleLabel.setText(article.displayTitle ?? AppStrings.untitledArticle, lineSpacing: 6)

        timeLabel.text = DateHelper.timeAgo(from: article.publishedAt)
        clockImageView.isHidden = timeLabel.text == nil

        articleImageView.setImage(with: article.imageURL)

        let body = article.displayBody ?? AppStrings.noDetails
        bodyLabel.setText(body, lineSpacing: 10)

        // Some articles have a missing or broken link
        readFullArticleButton.isHidden = article.articleURL == nil
    }

    private func updateFavoriteButton() {
        let isFavorite = favoritesManager.isFavorite(article)
        favoriteButton.setImage(isFavorite ? AppIcons.favoriteSaved : AppIcons.favorite, for: .normal)
        favoriteButton.accessibilityLabel = isFavorite ? AppStrings.removeFavorite : AppStrings.addFavorite
    }

    // MARK: - Actions

    @objc private func backTapped() {
        navigationController?.popViewController(animated: true)
    }

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
