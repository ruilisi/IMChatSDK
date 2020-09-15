//
//  UnifyDataConfig.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/9/9.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import Foundation

open class UnifyDataConfig {
    var baseUrl = String()
    var roomID = String()
    var userID = String()
    var userToken = String()
    var welcomText = "Welocm to the room!"
    var loadCount = 20
    
    public init() {
    }
    
    public func setUrl(url: String) -> UnifyDataConfig {
        baseUrl = url
        return self
    }
    
    public func setRoomID(rid: String) -> UnifyDataConfig {
        roomID = rid
        return self
    }
    
    public func setUserID(uid: String) -> UnifyDataConfig {
        userID = uid
        return self
    }
    
    public func setToken(token: String) -> UnifyDataConfig {
        userToken = token
        return self
    }
    
    public func setWelcome(text: String) -> UnifyDataConfig {
        welcomText = text
        return self
    }
    
    public func setPreLoadHistoryCount(count: Int) -> UnifyDataConfig {
        loadCount = count
        return self
    }
}
