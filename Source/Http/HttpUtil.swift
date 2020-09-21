//
//  HttpUtil.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/9/10.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//
import Foundation
import SwiftyJSON
import Alamofire

class HttpUtil {
    static func handleSuccessData(_ response: DataResponse<Any>, onSuccess: ((_ result: JSON) -> Void)?, defaultMessage: Bool) {
        guard let data = response.data, let json = try? JSON(data: data) else { return }
        onSuccess?(json)
        if let noMessage = json["noMessage"].bool, noMessage { return }
        if let message = json["message"].string, !message.isEmpty {
            print("Request Message: \(message)")
        } else if defaultMessage && !(json["ok"].bool ?? true) {
            print("Request Failed")
        }
    }
    
    static func hanndleFailure(_ response: DataResponse<Any>) {
        print("Requesrr Error, Code: \(response.response?.statusCode)")
    }
    
    static func post(_ url: String,
                     params: Parameters?,
                     header: [String: String],
                     onFailure: ((_ error: Error) -> Void)?,
                     onSuccess: ((_ result: JSON) -> Void)?) {
        sendRequest(url, params: defaultParams().merging(params ?? [:]) { (current, _) in current }, onFailure: onFailure, onSuccess: onSuccess, header: header, method: .post)
    }
    
    static func put(_ url: String,
                     params: Parameters?,
                     header: [String: String],
                     onFailure: ((_ error: Error) -> Void)?,
                     onSuccess: ((_ result: JSON) -> Void)?) {
        sendRequest(url, params: defaultParams().merging(params ?? [:]) { (current, _) in current }, onFailure: onFailure, onSuccess: onSuccess, header: header, method: .put)
    }

    static func get(_ url: String,
                    params: Parameters?,
                    header: [String: String],
                    onFailure: ((_ error: Error) -> Void)?,
                    onSuccess: ((_ result: JSON) -> Void)?) {
        sendRequest(url, params: defaultParams().merging(params ?? [:]) { (current, _) in current }, onFailure: onFailure, onSuccess: onSuccess, header: header, method: .get)
    }
    
    static func sendRequest(_ url: String,
                            params: Parameters?,
                            onFailure: ((_ error: Error) -> Void)?,
                            onSuccess: ((_ result: JSON) -> Void)?,
                            header: [String: String],
                            method: HTTPMethod = .post
        ) {
        HttpManager.one.request(url, method: method, parameters: params, encoding: method == .get ? URLEncoding.default : JSONEncoding.default, headers: header).validate(statusCode: 200..<300).responseJSON { response in
            switch response.result {
            case .success:
                handleSuccessData(response, onSuccess: onSuccess, defaultMessage: true)
            case .failure(let error):
                hanndleFailure(response)
                if let failed = onFailure { failed(error) }
            }
        }
    }
    
    static func defaultParams() -> Parameters {
        return [
            "DEVICE_TYPE": "IOS",
            "locale": Locale.current.languageCode ?? "en"
        ]
    }
}

extension Dictionary {
    func percentEncoded() -> Data? {
        return map { key, value in
            let escapedKey = "\(key)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            let escapedValue = "\(value)".addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? ""
            return escapedKey + "=" + escapedValue
        }
        .joined(separator: "&")
        .data(using: .utf8)
    }
}

extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        let generalDelimitersToEncode = ":#[]@" // does not include "?" or "/" due to RFC 3986 - Section 3.4
        let subDelimitersToEncode = "!$&'()*+,;="

        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "\(generalDelimitersToEncode)\(subDelimitersToEncode)")
        return allowed
    }()
}
