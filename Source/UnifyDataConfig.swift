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
    var perCount = 10
    var timespan = 600
    
    public init() {
    }
    
    
    /**
     设置服务端地址
     - parameters:
        - url: 服务端地址(wss://.../websocket)
     */
    public func setUrl(url: String) -> UnifyDataConfig {
        baseUrl = url
        return self
    }
    
    /**
     设置服务坐席ID
     - parameters:
        - rid: 坐席编号
     */
    public func setRoomID(rid: String) -> UnifyDataConfig {
        roomID = rid
        return self
    }
    
    /**
     设置用户的唯一ID
     - parameters:
        - uid: 用户ID
     */
    public func setUserID(uid: String) -> UnifyDataConfig {
        userID = uid
        return self
    }
    
    /**
     设置用户的Token
     - parameters:
        - token: 用户Token
     */
    public func setToken(token: String) -> UnifyDataConfig {
        userToken = token
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
}
