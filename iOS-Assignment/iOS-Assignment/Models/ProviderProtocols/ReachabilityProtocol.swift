//
//  ReachabilityProtocol.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 03/11/26.
//

import Foundation

protocol ReachabilityProtocol: AnyObject {
    var isConnected: Bool { get }
    // Called on the main thread when the connection goes up or down
    var onChange: (() -> Void)? { get set }
}
