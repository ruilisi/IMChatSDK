//
//  HttpRequest.swift
//  IMChatSDK
//
//  Created by 徐文杰 on 2020/10/9.
//

import Foundation
import SwiftyJSON

class HttpRequest {
    static func httpPost(baseUrl: String,
                         params: [String: Any]?,
                         onSuccess: ((_ result: JSON) -> Void)?,
                         onFailure: ((_ result: Error) -> Void)?) {
        let url = URL(string: baseUrl)!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        
        let parameters: [String: Any] = [
            "DEVICE_TYPE": "IOS",
            "locale": Locale.current.languageCode ?? "en"
        ].merging(params ?? [:]) { (current, _) in current }
        
        let jsonData = try? JSONSerialization.data(withJSONObject: parameters)
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data,
                let response = response as? HTTPURLResponse,
                error == nil else {                // check for fundamental networking error
                print("error", error ?? "Unknown error")
                return
            }
            
            if let errorMessage = error {
                onFailure?(errorMessage)
            }

            guard (200 ... 299) ~= response.statusCode else {                    // check for http errors
                print("statusCode should be 2xx, but is \(response.statusCode)")
                print("response = \(response)")
                return
            }

            let responseString = String(data: data, encoding: .utf8)
            print("responseString = \(responseString)")
            
            guard let json = try? JSON(data: data) else { return }
            onSuccess?(json)
        }

        task.resume()
    }
}
