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
import Lottie

enum HistoryTimeInterval {
    case latest
    case none
}

class IMTableView: UIView {
    
    var socket = WebSocketHelper()
    let messageTable = UITableView()
    var retryCount = 0
    var sendingList: [[String]] = []
    var lossConnect: Bool = false
    var isAlive: Bool = false
    var lossTimeInterval: Int = 0
    let refreshControl = UIRefreshControl()
    var cells: [MessageTableViewCell] = []
    var errorAction: (() -> Void)?
    var completeAction: (() -> Void)?
    var dataConfig = UnifyDataConfig()
    
    var sendBG = UIImage(named: "bgSend", in: Resources.bundle, compatibleWith: nil)
    var receiveBG = UIImage(named: "bgReceive", in: Resources.bundle, compatibleWith: nil)
    var sendEdge = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    var receiveEdge = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    var sendColor: UIColor = .white
    var receiveColor: UIColor = .white
    var timeColor: UIColor = .white
    var lottieanim: Animation? = nil
    var emptyHeight: CGFloat {
        get {
            return CGFloat.maximum(0, vHeight - messageTable.contentSize.height)
        }
    }
    
    var contentHeight: CGFloat {
        messageTable.layoutIfNeeded()

        return messageTable.contentSize.height
    }
    
    var viewHeight: CGFloat {
        self.layoutIfNeeded()
        return self.vHeight
    }
    
    var bgColor: UIColor? {
        get {
            return messageTable.backgroundColor
        }
        
        set {
            messageTable.backgroundColor = newValue
        }
    }
    
    var separatorColor: UIColor? {
        get {
            return messageTable.separatorColor
        }
        
        set {
            messageTable.separatorColor = newValue
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(messageTable)
        messageTable.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            .init(item: messageTable, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0),
            .init(item: messageTable, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: messageTable, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0),
            .init(item: messageTable, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)])
        setTable()
    }
    
    func setRefresh() {
        messageTable.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
    }
    
    // MARK: - 初始化SOCKET
    func build(config: UnifyDataConfig) {
        dataConfig = config
        isAlive = true
        print("isAlive: \(isAlive)")
        
        // 用户不一致，token过期
        if dataConfig.username != HistoryDataAccess.userName || timeNow - HistoryDataAccess.timeRecord > 10 {
            getData()
        } else {
            connectToWebSocket()
        }
    }
    
    func getData() {
        HttpRequest.httpPost(baseUrl: "https://api.chatsdk.io/customers/client_connect",
                             params: ["name": dataConfig.username,
                                      "api_key": dataConfig.apiKey,
                                      "department_id": dataConfig.departmentid],
                             onSuccess: { value in
                                print(value)
                                HistoryDataAccess.userName = self.dataConfig.username
                                
                                // 用户变更
                                if value["id"].stringValue != self.dataConfig.userID {
                                    HistoryDataAccess.historyData = []
                                    self.cleanHistory()
                                }
                                
                                self.dataConfig.baseUrl = value["base"].stringValue
                                self.dataConfig.webSocket = value["base"].stringValue.webSocketURL
                                self.dataConfig.userToken = value["token"].stringValue
                                self.dataConfig.roomID = value["rid"].stringValue
                                self.dataConfig.userID = value["id"].stringValue
                                self.dataConfig.wait = value["wait"].intValue
                                self.dataConfig.welcomText = value["template"].stringValue
                                self.dataConfig.timeout = value["timeout"].intValue
                                self.dataConfig.agentemail = value["agent_email"].stringValue
                                HistoryDataAccess.timeRecord = timeNow
                                self.connectToWebSocket()
                                globalDataConfig = self.dataConfig
                             },
                             onFailure: { value in
                                print(value)
                             })
    }
    
    func connectToWebSocket() {
        if !HistoryDataAccess.historyData.isEmpty {
            if let action = completeAction { action() }
            if cells.isEmpty {
                insertHistory(data: HistoryDataAccess.historyData)
            }
        }
        
        socket = WebSocketHelper(baseurl: dataConfig.webSocket)
        socket.delegate = self
    }
    
    func setTable() {
        messageTable.delegate = self
        messageTable.dataSource = self
        messageTable.backgroundView = nil
        messageTable.backgroundColor = .clear
        messageTable.separatorColor = .clear
        messageTable.reloadData()
    }
    
    func setReceiveBG(img: UIImage?, edge: UIEdgeInsets) {
        receiveBG = img
        receiveEdge = edge
    }
    
    func setSendBG(img: UIImage?, edge: UIEdgeInsets) {
        sendBG = img
        sendEdge = edge
    }
    
    func setReceiveColor(color: UIColor) {
        receiveColor = color
    }
    
    func setSendColor(color: UIColor) {
        sendColor = color
    }
    
    func setTimeColor(color: UIColor) {
        timeColor = color
    }
    
    func setLottie(lottie: Animation) {
        lottieanim = lottie
    }
    
    // MARK: - 载入历史
    func historyLoad() {
        guard !HistoryDataAccess.historyData.isEmpty else { return }
        self.cells = []
        
        for item in HistoryDataAccess.historyData {
            
            let cell = configCell()
            
            var timeinterval = TimeInterval(item.timeInterval / 1000)
            if item.timeInterval == 0 {
                timeinterval = Date().timeIntervalSince1970
            }
            
            let hidetime = needHide(timeInterval: Int(timeinterval))
            
//            cell.setContent(msgID: item.msgID, name: item.name, message: item.message, timeInterval: timeinterval, isSelf: item.bySelf, ishideTime: hidetime)
            cell.setContent(baseUrl: dataConfig.baseUrl, messageContent: item, ishideTime: hidetime)
            cell.setLoading(isLoading: false)
            cells.append(cell)
        }
        messageTable.reloadData()
        
        guard !cells.isEmpty else { return }
        
        messageTable.scrollToRow(at: IndexPath(row: cells.count - 1, section: 0), at: .none, animated: true)
    }
    
    // MARK: - 插入行
    func insertRow(message: MessageModel, desc: Bool = false, send: Bool = false, needhide: Bool = true) {
        
        
        let cell = configCell()
        var timeinterval = TimeInterval(message.timeInterval / 1000)
        if message.timeInterval == 0 {
            timeinterval = Date().timeIntervalSince1970
        }
        
        DispatchQueue.main.async {
            let filcell = self.cells.filter {
                return $0.messageID == message.msgID
            }
            
            guard filcell.isEmpty else { return }
            
            var hidetime = false
            
            hidetime = !needhide ? needhide : self.needHide(timeInterval: Int(timeinterval), desc: desc)
            
//            cell.setContent(msgID: message.msgID, name: message.name, message: message.message, timeInterval: timeinterval, isSelf: message.bySelf, ishideTime: hidetime)
            cell.setContent(baseUrl: self.dataConfig.baseUrl, messageContent: message, ishideTime: hidetime)
            
            if message.bySelf, send {
                cell.setLoading(isLoading: true)
            }
            
            self.addCellRow(cell: cell, desc: desc, byself: message.bySelf)
        }
    }
    
    func configCell() -> MessageTableViewCell {
        let cell = MessageTableViewCell()
        
        cell.sendEdge = sendEdge
        cell.receiveEdge = receiveEdge
        cell.sendBG = sendBG
        cell.receiveBG = receiveBG
        cell.sendColor = sendColor
        cell.receiveColor = receiveColor
        cell.timeColor = timeColor
        cell.anim = lottieanim
        
        return cell
    }
    
    func addCellRow(cell: MessageTableViewCell, desc: Bool, byself: Bool) {
        DispatchQueue.main.async {
            if !desc {
                self.cells.append(cell)
            } else {
                self.cells.insert(cell, at: 0)
            }
            
//            if !desc {
                self.messageTable.beginUpdates()
                self.messageTable.insertRows(at: [IndexPath(row: desc ? 0 : self.cells.count - 1, section: 0)], with: .automatic)
                self.messageTable.endUpdates()
//            } else {
//                self.messageTable.insertItemsAtTopWithFixedPosition(1)
//            }
            
            if !desc {
                self.messageTable.scrollToRow(at: IndexPath(row: self.cells.count - 1, section: 0), at: .bottom, animated: true)
            }
        }
    }
    
    func needHide(timeInterval: Int, desc: Bool = false) -> Bool {
        var hidetime = false
        if cells.count >= 1 {
            if !desc {
                let time = cells[cells.count - 1].timeInt
                if timeInterval - time < dataConfig.timespan {
                    hidetime = true
                }
            } else {
                let time = cells[0].timeInt
                if time - timeInterval < dataConfig.timespan {
                    hidetime = true
                }
            }
        }
        return hidetime
    }
    
    
    // MARK: - 按数量获取历史消息
    func getHistory(type: HistoryTimeInterval, count: Int) {
        
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
    
    // MARK: - 发送消息
    func sendMessage(message: String) {
        
        let msgID = Helper.createID()
        
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
    func cleanHistory() {
        HistoryDataAccess.historyData = []
        cells = []
        DispatchQueue.main.async {
            self.messageTable.reloadData()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - ACTIONS
extension IMTableView {
    @objc private func refreshWeatherData(_ sender: Any) {
        getHistory(type: .latest, count: dataConfig.perCount)
    }
}

// MARK: - TBALE代理
extension IMTableView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cells.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        print("RowHeight: \(cells[indexPath.row].rowHeight)")
        return cells[indexPath.row].rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = cells[indexPath.row]
        cell.selectionStyle = .none
        
        return cell
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        superview?.endEditing(true)
    }
    
    func getCellRectFromSuperView(_ rect: CGRect) -> CGRect {
        return messageTable.convert(rect, to: self.superview)
    }
}

extension UIScrollView {
    func scrollToBottom(animated: Bool) {
        self.setNeedsLayout()
        self.layoutIfNeeded()
        var originy: CGFloat = 0.0
        let height = self.frame.size.height
        if self.contentSize.height > height {
            originy = self.contentSize.height - height
        }
        self.setContentOffset(CGPoint(x: 0, y: originy), animated: animated)
    }
}
