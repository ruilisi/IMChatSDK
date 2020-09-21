//
//  HttpManager.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/9/10.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//
import Foundation
import Alamofire

class HttpManager: Alamofire.SessionManager {
    static let defaultURLSessionConfiguration: URLSessionConfiguration = {
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        configuration.timeoutIntervalForRequest = 10
        configuration.timeoutIntervalForResource = 10
        configuration.requestCachePolicy = .useProtocolCachePolicy
        configuration.connectionProxyDictionary = [AnyHashable : Any]()
        configuration.httpMaximumConnectionsPerHost = 100
        configuration.urlCache = nil
        return configuration
    }()
    
    class CustomServerTrustPolicyManager: ServerTrustPolicyManager {
        override func serverTrustPolicy(forHost host: String) -> ServerTrustPolicy? {
            return ServerTrustPolicy.disableEvaluation
        }
    }
    
    static let one = HttpManager(
        configuration: defaultURLSessionConfiguration,
        serverTrustPolicyManager: CustomServerTrustPolicyManager(policies: [:])
    )
}
