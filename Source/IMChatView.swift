//
//  IMChatView.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/9/10.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import UIKit

open class IMChatView: UIView {
    
    let bottomView = UIView()
    let textView = UITextView()
    let sendButton = UIButton()
    let bottomSafeArea = UIView()
    let messageTable = IMTableView()
    
    var bottomHeight = CGFloat()
    var navHeight = CGFloat()
    var tableHeight = CGFloat()
    var tableOriginY = CGFloat()
    var textviewHeight = CGFloat()
    var safeareaTop = CGFloat()
    var safeareaBottom = CGFloat()
    
    private var placeHoderColor: UIColor = .lightGray
    private var textColor: UIColor = .white
    
    public var completeAction: (() -> Void)? {
        get {
            return messageTable.completeAction
        }
        
        set {
            messageTable.completeAction = newValue
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow {
                safeareaTop = window.safeAreaInsets.top
                safeareaBottom = window.safeAreaInsets.bottom
            }
        }
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        self.addGestureRecognizer(tap)
        self.addSubview(messageTable)
        self.addSubview(bottomSafeArea)
        self.addSubview(bottomView)
        
        messageTable.bgColor = .clear
        messageTable.separatorColor = .clear
        
        setBottomView()
        setMsgView()
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.keyboardNotification(notification:)),
        name: UIResponder.keyboardWillChangeFrameNotification,
        object: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

public extension IMChatView {
    
    public func setFrame(_ rect: CGRect) {
        self.frame = rect
        setBottomView()
        setMsgView()
    }
    
    public func setBottomView() {
        let bottomViewWidth = frame.width
        let bottomViewHeight = 57.flo
        
        let btnWidth = CGFloat.minimum(frame.width * 0.16, 120)
        let inputWidth = frame.width * 0.85 - btnWidth
        
        bottomView.addSubview(textView)
        bottomView.addSubview(sendButton)
        
        bottomView.frame = CGRect(x: 0, y: frame.height - bottomViewHeight - safeareaBottom, width: bottomViewWidth, height: bottomViewHeight)
        bottomView.backgroundColor = .clear
        bottomHeight = bottomView.vHeight
        
        bottomSafeArea.frame = CGRect(x: 0, y: frame.height - bottomViewHeight - safeareaBottom, width: frame.width, height: safeareaBottom + bottomViewHeight)
        bottomSafeArea.backgroundColor = .clear
        
        textviewHeight = bottomViewHeight * 0.66
        textView.frame = CGRect(x: frame.width * 0.05, y: bottomViewHeight * 0.16, width: inputWidth, height: textviewHeight)
        textView.backgroundColor = .white
        textView.delegate = self
        textView.textColor = placeHoderColor
        textView.text = "说点什么吧"
        textView.layer.cornerRadius = 4
        textView.textContainer.lineFragmentPadding = 10
        textView.font = UIFont.systemFont(ofSize: textView.vHeight * 0.45, weight: .regular)
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        bottomView.addConstraints([
            .init(item: sendButton, attribute: .centerY, relatedBy: .equal, toItem: textView, attribute: .centerY, multiplier: 1, constant: 0),
            .init(item: sendButton, attribute: .trailing, relatedBy: .equal, toItem: bottomView, attribute: .trailing, multiplier: 1, constant: -frame.width * 0.05),
            .init(item: sendButton, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: btnWidth),
            .init(item: sendButton, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: bottomViewHeight * 0.55)])
        sendButton.setTitle("发送", for: .normal)
        sendButton.layer.cornerRadius = 4
        sendButton.backgroundColor = .white
        sendButton.addTarget(self, action: #selector(sendMsg), for: .touchUpInside)
    }
    
    // MARK: - 消息列表
    public func setMsgView() {
        messageTable.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraints([
            .init(item: messageTable, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0),
            .init(item: messageTable, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0),
            .init(item: messageTable, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0),
            .init(item: messageTable, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: 0)])
    }
}

// MARK: - 事件

extension IMChatView {
    @objc func sendMsg() {
        if let msg = textView.text, ImDataAccess.imInfor != nil, !msg.isEmpty {
            messageTable.sendMessage(message: msg)
            self.textView.text = ""
            self.textViewDidChange(textView)
        }
    }
    
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        self.endEditing(true)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        var tmp: CGFloat = 0
        //UIKeyboardFrameEndUserInfoKey
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let endFrameY = keyboardRectangle.origin.y
            
            if endFrameY >= UIScreen.main.bounds.size.height {
                tmp = 0.0
            } else {
                tmp = keyboardRectangle.size.height
            }
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            self.bottomView.originY = self.frame.height - self.bottomView.vHeight - tmp - (tmp > 0 ? 0 : self.safeareaBottom)
        })
    }
}

extension IMChatView: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let range = (newSize.height - textView.vHeight)
        
        if textView.vHeight > 100, range > 0 {
            return
        }
        
        textView.vHeight += range
        
        bottomView.vHeight += range
        bottomView.originY -= range
        
        sendButton.originY -= range * 0.5
    }
    
    public func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return true
    }
    
    public func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == placeHoderColor {
            textView.text = nil
            textView.textColor = textColor
        }
    }
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "说点什么吧"
            textView.textColor = placeHoderColor
        }
    }
}

public extension IMChatView {
    func cleanHistory() {
        messageTable.cleanHistory()
    }
    
    func disconnect() {
        messageTable.disconnect()
    }
    
    func buildConnection(config: UnifyDataConfig) {
        messageTable.build(config: config)
    }
    
    func buildUI(config: UnifyUIConfig) {
        
        if config.backgroundColor != nil {
            self.backgroundColor = config.backgroundColor
        }
        
        if config.bottomColor != nil {
            self.bottomView.backgroundColor = config.bottomColor
            self.bottomSafeArea.backgroundColor = config.bottomColor
        }
        
        if let color = config.textColor {
            self.textColor = color
        }
        
        if let color = config.placeHolderColor {
            self.textView.textColor = color
            self.placeHoderColor = color
        }
        
        if config.buttonColor != nil {
            self.sendButton.backgroundColor = config.buttonColor
        }
        
        if config.textbgColor != nil {
            self.textView.backgroundColor = config.textbgColor
        }
        
        if let img = config.sendBG, let edge = config.sendEdge {
            messageTable.setSendBG(img: img, edge: edge)
        }
        
        if let img = config.receiveBG, let edge = config.receiveEdge {
            messageTable.setReceiveBG(img: img, edge: edge)
        }
    }
}
