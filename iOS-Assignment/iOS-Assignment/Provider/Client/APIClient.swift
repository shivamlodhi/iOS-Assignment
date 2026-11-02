//
//  APIClient.swift
//  iOS-Assignment
//
//  Created by Shivam Lodhi on 02/11/26.
//

import Foundation
import Alamofire
import XCGLogger

final class APIClient {

    private let session: Session

    init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 20
        session = Session(configuration: configuration)
    }

    func get<T: Decodable>(_ url: String, completion: @escaping (Result<T, APIError>) -> Void) {
        log.info("Request: GET \(url)")

        session.request(url)
            .validate()
            .responseDecodable(of: T.self) { response in
                let statusCode = response.response?.statusCode ?? 0

                switch response.result {
                case .success(let value):
                    log.debug("Response: \(statusCode) \(url)")
                    completion(.success(value))
                case .failure(let error):
                    log.error("Request failed: \(statusCode) \(url) - \(error.localizedDescription)")
                    completion(.failure(APIError(error)))
                }
            }
    }
}
