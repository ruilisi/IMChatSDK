//
//  ImDataAccess.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/8/27.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import Foundation
import SwiftyJSON

class ImDataAccess {
    
    static var imInfors: ImInfo? = imInitial()
    static let IMKey = "eSheep.IM"
    static var imInfor: ImInfo? {
        get {
            return imInfors
        }
        
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: IMKey)
            imInfors = newValue
        }
    }
    
    static func sync(_ data: JSON) {
        let next = ImInfo(
            base: data["base"].stringValue,
            welcome: data["config"]["welcome"].stringValue,
            myid: data["_id"].stringValue,
            roomid: data["rid"].stringValue,
            token: data["token"].stringValue,
            username: data["username"].stringValue,
            status: data["status"].stringValue)
        
        imInfor = next
    }
    
    static func imInitial() -> ImInfo? {
        guard let data = UserDefaults.standard.data(forKey: IMKey) else { return nil }
        guard let imdata = try? JSONDecoder().decode(ImInfo.self, from: data) else { return nil }
        return imdata
    }
}
