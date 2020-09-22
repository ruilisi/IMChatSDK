//
//  HistoryDataAccess.swift
//  IMChatSDK
//
//  Created by 徐文杰 on 2020/9/17.
//

import Foundation

typealias HistoryList = [MessageModel]
let HISTORYKEY = "CHAT.HistoryKey"
let USERNAME = "CHAT.UserName"
let TIMEKEY = "CHAT.TimeKey"

class HistoryDataAccess {
    
    static private var historyDatas: HistoryList = historyInitial()
    static private var userNames: String = usernameInitial()
    static private var timeRecords: Int = timerecordInitial()
    
    static var historyData: HistoryList {
        get {
            return historyDatas
        }
        
        set {
            let data = try? JSONEncoder().encode(newValue)
            UserDefaults.standard.set(data, forKey: HISTORYKEY)
            historyDatas = newValue
        }
    }
    
    static var userName: String {
        get {
            return userNames
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: USERNAME)
            userNames = newValue
        }
    }
    
    static var timeRecord: Int {
        get {
            return timeRecords
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: TIMEKEY)
            timeRecords = newValue
        }
    }
    
    static func appendMessage(message: MessageModel) {
        historyData.append(message)
        
        if historyData.count > 100 {
            historyData.remove(at: 0)
        }
        
        print("History Count: \(historyData.count)")
    }
    
    static func insertMessage(messag: MessageModel) {
        if historyData.count < 100 {
            historyData.insert(messag, at: 0)
        }
    }
    
    static func historyInitial() -> HistoryList {
        guard let data = UserDefaults.standard.data(forKey: HISTORYKEY) else { return [] }
        guard let historyList = try? JSONDecoder().decode(HistoryList.self, from: data) else { return [] }
        return historyList
    }
    
    static func usernameInitial() -> String {
        guard let userName = UserDefaults.standard.string(forKey: USERNAME) else { return "" }
        return userName
    }
    
    static func timerecordInitial() -> Int {
        let tick = UserDefaults.standard.integer(forKey: TIMEKEY)
        return tick
    }
}
