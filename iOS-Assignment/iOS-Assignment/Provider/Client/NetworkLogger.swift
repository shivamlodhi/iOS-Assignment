//
//  NetworkLogger.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation
import Alamofire
import XCGLogger

final class NetworkLogger: EventMonitor {

    let queue = DispatchQueue(label: "com.shivamapptest.networklogger")

    func requestDidResume(_ request: Request) {
        log.info("Request: \(request.request?.httpMethod ?? "") \(request.request?.url?.absoluteString ?? "")")
    }

    func request<Value>(_ request: DataRequest, didParseResponse response: DataResponse<Value, AFError>) {
        let url = request.request?.url?.absoluteString ?? ""
        let statusCode = response.response?.statusCode ?? 0

        switch response.result {
        case .success:
            log.debug("Response: \(statusCode) \(url) (\(response.data?.count ?? 0) bytes)")
        case .failure(let error):
            log.error("Request failed: \(statusCode) \(url) - \(error.localizedDescription)")
        }
    }
}
