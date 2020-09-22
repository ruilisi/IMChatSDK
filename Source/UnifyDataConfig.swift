//
//  UnifyDataConfig.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/9/9.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import Foundation

let URLKEY = "CHAT.UrlKey"
let USERKEY = "CHAT.UserKey"
let ROOMKEY = "CHAT.RoomKey"
let TOKENKEY = "CHAT.TokenKey"

open class UnifyDataConfig {
    
    var welcomText = "Welocm to the room!"
    var wait = 0
    var loadCount = 20
    var perCount = 10
    var timespan = 600
    
    var apiKey = String()
    var departmentid = String()
    var username = String()
    
    var baseUrl: String {
        get {
            return urlInitial()
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: URLKEY)
        }
    }
    var roomID: String {
        get {
            return roomInitial()
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: ROOMKEY)
        }
    }
    var userToken: String {
        get {
            return tokenInitial()
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: TOKENKEY)
        }
    }
    var userID: String {
        get {
            return userIDInitial()
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: USERKEY)
        }
    }
    
    public init() {
    }
    
    /**
     设置API Key
     - parameters:
        - key: API Key
     */
    public func setApiKey(key: String) -> UnifyDataConfig {
        apiKey = key
        return self
    }
    
    /**
     设置部门ID
     - parameters:
        - did: 部门ID
     */
    public func setDepartmentID(did: String) -> UnifyDataConfig {
        departmentid = did
        return self
    }
    
    /**
     设置用户的名称
     - parameters:
        - uname: 用户名称
     */
    public func setUserName(uname: String) -> UnifyDataConfig {
        username = uname
        return self
    }
    
    /**
     设置欢迎语句
     - parameters:
        - text: 欢迎语句内容
     */
    public func setWelcome(text: String) -> UnifyDataConfig {
        welcomText = text
        return self
    }
    
    /**
     设置载入的历史数量
     - parameters:
        - count: 数量
     */
    public func setLoadHistoryCount(count: Int) -> UnifyDataConfig {
        loadCount = count
        return self
    }
    
    /**
     设置每次载入的历史数量
     - parameters:
        - count: 数量
     */
    public func setPerLoadHistoryCount(count: Int) -> UnifyDataConfig {
        perCount = count
        return self
    }
    
    /**
     设置显示时间的间隔时长
     - parameters:
        - timeinterval: 时长(秒)
     */
    public func setTimeSpan(timeinterval: Int) -> UnifyDataConfig {
        timespan = timeinterval
        return self
    }
    
    private func urlInitial() -> String {
        guard let url = UserDefaults.standard.string(forKey: URLKEY) else { return "" }
        return url
    }
    
    private func roomInitial() -> String {
        guard let rid = UserDefaults.standard.string(forKey: ROOMKEY) else { return "" }
        return rid
    }
    
    private func tokenInitial() -> String {
        guard let token = UserDefaults.standard.string(forKey: TOKENKEY) else { return "" }
        return token
    }
    
    private func userIDInitial() -> String {
        guard let token = UserDefaults.standard.string(forKey: USERKEY) else { return "" }
        return token
    }
}
