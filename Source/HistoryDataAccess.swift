//
//  HistoryDataAccess.swift
//  IMChatSDK
//
//  Created by 徐文杰 on 2020/9/17.
//

import Foundation

typealias HistoryList = [MessageModel]
let HISTORYKEY = "HistoryKey"

class HistoryDataAccess {
    
    static private var historyDatas: HistoryList = historyInitial()
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
    
    static func insertMessage(message: MessageModel) {
        historyData.append(message)
        
        if historyData.count > 10 {
            historyData.remove(at: 0)
        }
        
        print("History Count: \(historyData.count)")
    }
    
    static func historyInitial() -> HistoryList {
        guard let data = UserDefaults.standard.data(forKey: HISTORYKEY) else { return [] }
        guard let tunnelList = try? JSONDecoder().decode(HistoryList.self, from: data) else { return [] }
        return tunnelList
    }
}
