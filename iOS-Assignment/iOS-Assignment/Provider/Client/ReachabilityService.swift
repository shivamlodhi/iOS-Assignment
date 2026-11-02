//
//  ReachabilityService.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation
import Reachability
import XCGLogger

extension Notification.Name {
    static let connectivityChanged = Notification.Name("connectivityChanged")
}

final class ReachabilityService: ReachabilityProtocol {

    private let reachability = try? Reachability()

    var isConnected: Bool {
        guard let reachability else { return true }
        return reachability.connection != .unavailable
    }

    func start() {
        reachability?.whenReachable = { [weak self] reachability in
            log.info("Connection available via \(reachability.connection)")
            self?.postChange()
        }
        reachability?.whenUnreachable = { [weak self] _ in
            log.warning("Connection lost")
            self?.postChange()
        }

        do {
            try reachability?.startNotifier()
        } catch {
            log.error("Unable to start reachability notifier: \(error.localizedDescription)")
        }
    }

    private func postChange() {
        NotificationCenter.default.post(name: .connectivityChanged, object: nil)
    }
}
