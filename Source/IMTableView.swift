//
//  IMTableView.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/8/28.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import UIKit
import Starscream
import SwiftyJSON

public enum HistoryTimeInterval {
    case latest
    case none
}

open class IMTableView: UIView {
    
    var socket = WebSocketHelper()
    let messageTable = UITableView()
    var retryCount = 0
    var sendingList: [[String]] = []
    var lossConnect: Bool = false
    var lossTimeInterval: Int = 0
    let refreshControl = UIRefreshControl()
    var historyDatas: [MessageModel] = []
    var cells: [MessageTableViewCell] = []
    var errorAction: (() -> Void)?
    public var completeAction: (() -> Void)?
    var dataConfig = UnifyDataConfig()
    
    var sendBG = UIImage(named: "bgSend")
    var receiveBG = UIImage(named: "bgReceive")
    var sendEdge = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    var receiveEdge = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    var historyData: [MessageModel] {
        get {
            return historyDatas
        }
        
        set {
            historyDatas = newValue
            historyLoad()
        }
    }
    
    var emptyHeight: CGFloat {
        get {
            return CGFloat.maximum(0, vHeight - messageTable.contentSize.height)
        }
    }
    
    public var bgColor: UIColor? {
        get {
            return messageTable.backgroundColor
        }
        
        set {
            messageTable.backgroundColor = newValue
        }
    }
    
    public var separatorColor: UIColor? {
        get {
            return messageTable.separatorColor
        }
        
        set {
            messageTable.separatorColor = newValue
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(messageTable)
        messageTable.refreshControl = refreshControl
        messageTable.translatesAutoresizingMaskIntoConstraints = false
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        self.addConstraints([
            .init(item: messageTable, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            .init(item: messageTable, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: messageTable, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0),
            .init(item: messageTable, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)])
        setTable()
    }
    
    // MARK: - 初始化SOCKET
    public func build(config: UnifyDataConfig) {
        dataConfig = config
        socket = WebSocketHelper(baseurl: dataConfig.baseUrl)
        socket.delegate = self
    }
    
    public func setTable() {
        messageTable.delegate = self
        messageTable.dataSource = self
        messageTable.backgroundView = nil
        messageTable.backgroundColor = .clear
        messageTable.separatorColor = .clear
        messageTable.reloadData()
    }
    
    public func setReceiveBG(img: UIImage?, edge: UIEdgeInsets) {
        receiveBG = img
        receiveEdge = edge
    }
    
    public func setSendBG(img: UIImage?, edge: UIEdgeInsets) {
        receiveBG = img
        receiveEdge = edge
    }
    
    // MARK: - 载入历史
    public func historyLoad() {
        guard !historyData.isEmpty else { return }
        self.cells = []
        for item in historyDatas {
            let cell = MessageTableViewCell()
            
            cell.sendEdge = sendEdge
            cell.receiveEdge = receiveEdge
            cell.sendBG = sendBG
            cell.receiveBG = receiveBG
            
            var timeinterval = TimeInterval(item.timeInterval / 1000)
            if item.timeInterval == 0 {
                timeinterval = Date().timeIntervalSince1970
            }
            
            cell.setContent(msgID: item.msgID, name: item.name, message: item.message, timeInterval: timeinterval, isSelf: item.bySelf)
            cell.setLoading(isLoading: false)
            cells.append(cell)
        }
        messageTable.reloadData()
        
        messageTable.scrollToRow(at: IndexPath(row: cells.count - 1, section: 0), at: .none, animated: true)
    }
    
    // MARK: - 插入行
    public func insertRow(message: MessageModel, desc: Bool = false, send: Bool = false) {
        let cell = MessageTableViewCell()
        var timeinterval = TimeInterval(message.timeInterval / 1000)
        if message.timeInterval == 0 {
            timeinterval = Date().timeIntervalSince1970
        }

        cell.sendEdge = sendEdge
        cell.receiveEdge = receiveEdge
        cell.sendBG = sendBG
        cell.receiveBG = receiveBG
        
        cell.setContent(msgID: message.msgID, name: message.name, message: message.message, timeInterval: timeinterval, isSelf: message.bySelf)
        
        if message.bySelf, send {
            cell.setLoading(isLoading: true)
        }
        
        messageTable.beginUpdates()
        
        if !desc {
            cells.append(cell)
            messageTable.insertRows(at: [IndexPath(row: cells.count - 1, section: 0)], with: .automatic)
        } else {
            cells.insert(cell, at: 0)
            messageTable.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
        }
        
        messageTable.endUpdates()
        
        messageTable.scrollToRow(at: IndexPath(row: !desc ? cells.count - 1 : 0, section: 0), at: !desc ? .bottom : .top, animated: true)
    }
    
    // MARK: - 连接服务器
    public func connectionToServer(token: String? = nil) {
        if let value = token {
            dataConfig.userToken = value
        }
        socket.connectServer()
        socket.loginServer(dataConfig.userToken)
        socket.subServer(createID(), dataConfig.userID)
    }
    
    // MARK: - 按数量获取历史消息
    public func getHistory(type: HistoryTimeInterval, count: Int) {
        
        var timeInterval: Int?
        
        switch type {
        case .none:
            break
        case .latest:
            guard !cells.isEmpty else { break }
            timeInterval = cells[0].timeInt * 1000
        }
        
        socket.getHistory(dataConfig.roomID, count, timeInterval)
    }
    
    // MARK: - 随机生成ID
    public func createID(_ seed: String = unmistakableChars) -> String {
        let count = seed.count
        var result = ""
        for _ in 0 ..< 17 {
            let chart = seed[Int.random(in: 0..<count)]
            result += chart
        }
        return result
    }
    
    // MARK: - 发送消息
    public func sendMessage(message: String) {
        
        let msgID = createID()
        
        let msg = MessageModel(
            msgID: msgID,
            name: "",
            message: message,
            timeInterval: Int(Date().timeIntervalSince1970) * 1000,
            roomID: dataConfig.roomID,
            bySelf: true)
        
        insertRow(message: msg, send: true)
        
        sendingList.append([msgID, message])
        
        if sendingList.count == 1 {
            socket.sendMsg(sendingList[0][0], sendingList[0][1], dataConfig.roomID)
        }
        
        print("befaoreSendingList:\(sendingList)")
    }
    
    // MARK: - 清空历史
    public func cleanHistory() {
        historyData = []
        cells = []
        self.messageTable.reloadData()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ACTIONS
extension IMTableView {
    @objc private func refreshWeatherData(_ sender: Any) {
        getHistory(type: .latest, count: 10)
    }
}

// MARK: - TBALE代理
extension IMTableView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cells[indexPath.row].bgimage.frame.height + 20
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = cells[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        superview?.endEditing(true)
    }
}

extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        var originy: CGFloat = 0.0
        let height = self.frame.size.height
        if self.contentSize.height > height {
            originy = self.contentSize.height - height
        }
        self.setContentOffset(CGPoint(x: 0, y: originy), animated: animated)
    }
}
