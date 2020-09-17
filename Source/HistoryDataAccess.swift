//
//  HistoryDataAccess.swift
//  IMChatSDK
//
//  Created by 徐文杰 on 2020/9/17.
//

import Foundation

typealias HistoryList = [MessageModel]
let HISTORYKEY = "HistoryKey"
let USERKEY = "UserKey"

class HistoryDataAccess {
    
    static private var historyDatas: HistoryList = historyInitial()
    static private var userIDs: String = useridInitial()
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
    
    static var userID: String {
        get {
            return userIDs
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: USERKEY)
            userIDs = newValue
        }
    }
    
    static func appendMessage(message: MessageModel) {
        historyData.append(message)
        
        if historyData.count > 10 {
            historyData.remove(at: 0)
        }
        
        print("History Count: \(historyData.count)")
    }
    
    static func insertMessage(messag: MessageModel) {
        if historyData.count < 10 {
            historyData.insert(messag, at: 0)
        }
    }
    
    static func historyInitial() -> HistoryList {
        guard let data = UserDefaults.standard.data(forKey: HISTORYKEY) else { return [] }
        guard let historyList = try? JSONDecoder().decode(HistoryList.self, from: data) else { return [] }
        return historyList
    }
    
    static func useridInitial() -> String {
        guard let userID = UserDefaults.standard.string(forKey: USERKEY) else { return "" }
        return userID
    }
}
