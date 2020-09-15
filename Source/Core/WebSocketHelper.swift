//
//  SocketHelper.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/8/27.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import Foundation
import Starscream
import UIKit

open class WebSocketHelper {
    
    var index = 0
    var socket: WebSocket?
    private var dokidoki: Timer?
    private var connectionstate = false
    var isConnected: Bool {
        get {
            return connectionstate
        }
        
        set {
            connectionstate = newValue
            if newValue {
                dokidoki = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(pingToServer), userInfo: nil, repeats: true)
                dokidoki?.fire()
            } else {
                dokidoki?.invalidate()
            }
        }
    }
    var pingCount = 0
    
    public init() {
        
    }
    
    var delegatex: WebSocketDelegate?
    var delegate: WebSocketDelegate? {
        get {
            return delegatex
        }
        
        set {
            socket?.delegate = newValue
        }
    }
    
    public init(baseurl: String) {
        guard let url = URL(string: baseurl) else { return }
        var request = URLRequest(url: url)
        request.timeoutInterval = 10
        socket = WebSocket(request: request)
        if let websocket = socket {
            websocket.connect()
        }
    }
    
    // MARK: - 连接服务器
    public func connectServer() {
        guard let websocket = socket else { return }
        let dict = [
            "msg": "connect",
            "support": ["1", "pre2", "pre1"],
            "version": "1"
        ] as [String: Any]
        let cmd = dictToJsonStr(dict)
        print("Send text: \(cmd)")
        websocket.write(string: cmd, completion: {
            print("Send Complete: \(cmd)")
        })
    }
    
    // MARK: - 登录服务器
    /**
           这个函数进行了登录操作
    
           - parameters:
               - token: 用户的Token
    */
    public func loginServer(_ token: String) {
        guard let websocket = socket else { return }
        let dict = [
            "id": "1",
            "method": "login",
            "msg": "method",
            "params": [
                ["resume": "\(token)"]
            ]] as [String: Any]
        let cmd = dictToJsonStr(dict)
        print("Send text: \(cmd)")
        websocket.write(string: cmd, completion: {
            print("Send Complete: \(cmd)")
        })
    }
    
    // MARK: - 接入服务器
    public func subServer(_ id: String, _ myID: String) {
        guard let websocket = socket else { return }
        let dict = ["id": id,
                    "msg": "sub",
                    "name": "stream-notify-user",
                    "params": ["\(myID)/notification", [
                        "args": [],
                        "useCollection": false
                        ]]] as [String: Any]
        let cmd = dictToJsonStr(dict)
        print("Send text: \(cmd)")
        websocket.write(string: cmd, completion: {
            print("Send Complete: \(cmd)")
        })
    }
    
    // MARK: - 发送信息
    public func sendMsg(_ id: String, _ msg: String, _ roomID: String) {
        guard let websocket = socket else { return }
        let dict = ["msg": "method",
                    "method": "sendMessage",
                    "params": [[
                        "_id": "\(id)",
                        "rid": "\(roomID)",
                        "msg": "\(msg)"
                        ]],
                    "id": "\(index)"] as [String: Any]
        let cmd = dictToJsonStr(dict)
        index += 1
        print("Send text: \(cmd)")
        websocket.write(string: cmd, completion: {
            print("Send Complete: \(cmd)")
        })
    }
    
    // MARK: - 获取历史消息
    public func getHistory(_ roomID: String, _ count: Int, _ timeInterval: Int? = nil) {
        guard let websocket = socket else { return }
        
        var startTime: [String: Int]?
        
        if let time = timeInterval {
            startTime = ["$date": time]
        }
        
        let dict = ["msg": "method",
                    "method": "loadHistory",
                    "params": ["\(roomID)", startTime, count, nil],
                    "id": "\(index)"] as [String: Any]
        index += 1
        let cmd = dictToJsonStr(dict)
        print("Send text: \(cmd)")
        websocket.write(string: cmd, completion: {
            print("Send Complete: \(cmd)")
        })
    }
    
    // MARK: - 获取丢失的消息
    public func getMissHistory(_ roomID: String, _ timeInterval: Int) {
        guard let websocket = socket else { return }
        
        let startTime: [String: Int] = ["$date": timeInterval]
        
        let dict = ["msg": "method",
                    "method": "loadMissedMessages",
                    "params": ["\(roomID)", startTime],
                    "id": "\(index)"] as [String: Any]
        index += 1
        let cmd = dictToJsonStr(dict)
        print("Send text: \(cmd)")
        websocket.write(string: cmd, completion: {
            print("Send Complete: \(cmd)")
        })
    }
    
    // MARK: - 从服务器断开连接
    public func disconnectFromServer() {
        isConnected = false
        guard let websocket = socket else { return }
        websocket.disconnect()
    }
    
    @objc func pingToServer() {
        let dict = ["msg": "ping"]
        let cmd = self.dictToJsonStr(dict)
        if !self.isConnected {
            dokidoki?.invalidate()
            return
        }
        print("Send text: \(cmd)")
        self.socket?.write(string: cmd, completion: {
            print("\(self.pingCount) ping Success")
            self.pingCount += 1
        })
    }
    
    public func dictToJsonStr(_ dict: [String: Any]) -> String {
        let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: [])
        guard let data = jsonData else { return "ERROR" }
        let jsonStr = String(data: data, encoding: .utf8)
        return (jsonStr ?? "").replacingOccurrences(of: "\\/", with: "/")
    }
}
