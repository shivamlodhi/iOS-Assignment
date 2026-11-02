//
//  StateView.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import SwiftUI

// Full screen message for offline, error, empty and no results states
struct StateView: View {

    let icon: String
    let title: String
    let message: String
    var onRetry: (() -> Void)?

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 56, weight: .light))
                .foregroundStyle(.primary)
                .padding(.bottom, 4)

            Text(title)
                .font(.headline)

            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let onRetry {
                if #available(iOS 26.0, *) {
                    Button(action: onRetry) { retryLabel }
                        .buttonStyle(.glass)
                } else {
                    Button(action: onRetry) {
                        retryLabel
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color(.systemGray6), in: Capsule())
                            .overlay(Capsule().stroke(Color(.systemGray4), lineWidth: 1))
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.offlineBackground))
    }

    private var retryLabel: some View {
        Label("Retry", systemImage: "arrow.counterclockwise")
            .font(.subheadline.weight(.semibold))
    }
}

extension StateView {

    static func offline(onRetry: @escaping () -> Void) -> StateView {
        StateView(icon: "wifi.slash", title: "You’re offline",
                  message: "Please connect to the internet and try again.", onRetry: onRetry)
    }

    static func error(_ error: APIError, onRetry: @escaping () -> Void) -> StateView {
        StateView(icon: "exclamationmark.triangle", title: "Something went wrong",
                  message: error.message, onRetry: onRetry)
    }

    static func empty(onRetry: @escaping () -> Void) -> StateView {
        StateView(icon: "newspaper", title: "No articles yet",
                  message: "There are no articles to show right now.", onRetry: onRetry)
    }

    static func noResults(for searchText: String) -> StateView {
        StateView(icon: "magnifyingglass", title: "No results",
                  message: "No articles match “\(searchText)”.")
    }
}

#Preview {
    StateView.offline {}
}
