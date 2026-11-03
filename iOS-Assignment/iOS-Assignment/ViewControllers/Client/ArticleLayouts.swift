//
//  ArticleLayouts.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 03/11/26.
//

import UIKit

// Collection view layouts for the article list
enum ArticleLayouts {

    static func list() -> UICollectionViewLayout {
        let size = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300))
        let item = NSCollectionLayoutItem(layoutSize: size)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: size, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.interGroupSpacing = 16
        section.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 16, trailing: 8)
        return UICollectionViewCompositionalLayout(section: section)
    }

    // One column for accessibility text sizes, two otherwise
    static func grid(isLargeText: Bool) -> UICollectionViewLayout {
        let columns = isLargeText ? 1 : 2
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
}
