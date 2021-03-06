//
//  IMChatView.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/9/10.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import UIKit
import Kingfisher
import AVKit
import AVFoundation
import MobileCoreServices

open class IMChatView: UIView {
    
    let bottomView = UIView()
    let textView = UITextView()
    let sendButton = UIButton()
    let bottomSafeArea = UIView()
    let messageTable = IMTableView()
    
    var bgHover = UIView()
    var alertImg = UIImageView()
    var showScroll = ImageScrollView()
    var imgFrame = CGRect()
    
    var parentController = UIViewController()
    
    var bottomHeight = CGFloat()
    var navHeight = CGFloat()
    var tableHeight = CGFloat()
    var tableOriginY = CGFloat()
    var textviewHeight = CGFloat()
    var safeareaTop = CGFloat()
    var safeareaBottom = CGFloat()
    var placeHolder: String = "说点什么吧"
    
    var selfY = CGFloat()
    var animtp = 0
    
    private var placeHoderColor: UIColor = .lightGray
    private var textColor: UIColor = .white
    var imagePicker: ImagePicker!
    
    var completeAction: (() -> Void)? {
        get {
            return messageTable.completeAction
        }
        
        set {
            messageTable.completeAction = newValue
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        selfY = frame.origin.y        
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
        
        bottomView.addSubview(textView)
        bottomView.addSubview(sendButton)
        
        messageTable.bgColor = .clear
        messageTable.separatorColor = .clear
        
        setBottomView()
        setConstraints()
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(self.keyboardNotification(notification:)),
        name: UIResponder.keyboardWillChangeFrameNotification,
        object: nil)
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(showImage(_:)), name: NSNotification.Name(rawValue: "showImage"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showVideo(_:)), name: NSNotification.Name(rawValue: "showVideo"), object: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension IMChatView {
    
    func setBottomView() {
        let bottomViewWidth = frame.width
        let bottomViewHeight = 57.flo
        
        let btnWidth = CGFloat.minimum(frame.width * 0.16, 120)
        let inputWidth = frame.width * 0.85 - btnWidth
        
        bottomView.backgroundColor = .clear
        bottomHeight = bottomView.vHeight
        
        bottomSafeArea.frame = CGRect(x: 0, y: frame.height - bottomViewHeight - safeareaBottom, width: bottomViewWidth, height: safeareaBottom + bottomViewHeight)
        bottomSafeArea.backgroundColor = .clear
        
        textviewHeight = bottomViewHeight * 0.66
        textView.frame = CGRect(x: frame.width * 0.06, y: bottomViewHeight * 0.16, width: inputWidth, height: textviewHeight)
        
        textView.backgroundColor = .white
        textView.delegate = self
        textView.textColor = placeHoderColor
        textView.text = placeHolder
        textView.layer.cornerRadius = 3
        textView.textContainer.lineFragmentPadding = 10
        textView.font = UIFont.systemFont(ofSize: textView.vHeight * 0.45, weight: .regular)
        
        sendButton.setTitle("发送", for: .normal)
        sendButton.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        sendButton.layer.cornerRadius = 3
        sendButton.backgroundColor = .white
        sendButton.addTarget(self, action: #selector(sendMsg), for: .touchUpInside)
    }
    
    func setConstraints() {
        messageTable.translatesAutoresizingMaskIntoConstraints = false
        messageTable.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        messageTable.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        messageTable.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        messageTable.bottomAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -safeareaBottom).isActive = true
        bottomView.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        bottomView.heightAnchor.constraint(equalTo: textView.heightAnchor, constant: 20).isActive = true
        
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.centerYAnchor.constraint(equalTo: textView.centerYAnchor).isActive = true
        sendButton.trailingAnchor.constraint(equalTo: bottomView.trailingAnchor, constant: -frame.width * 0.06).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: CGFloat.minimum(frame.width * 0.16, 120)).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        bottomView.layoutIfNeeded()
    }
}

// MARK: - 事件

extension IMChatView {
    @objc func sendMsg() {
        //发送图片测试：
//        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum), let parentVC = self.parentViewController{
//            imagePicker = ImagePicker(presentationController: parentVC, delegate: self)
//            imagePicker.present(from: parentVC.view)
//        }
//        return
        
        if let msg = textView.text, !msg.isEmpty, textView.isFirstResponder {
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
        var keyboardH: CGFloat = 0
        //UIKeyboardFrameEndUserInfoKey
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let endFrameY = keyboardRectangle.origin.y
            keyboardH = keyboardRectangle.size.height
            
            if endFrameY >= UIScreen.main.bounds.size.height {
                tmp = 0.0
            } else {
                tmp = keyboardH
            }
        }
        
        UIView.animate(withDuration: 0.1, animations: {
            
            guard self.messageTable.contentHeight + self.messageTable.viewHeight != 0 else { return }
            if self.messageTable.contentHeight < self.messageTable.viewHeight - keyboardH || self.animtp == 1 {
                
                self.bottomView.originY = self.frame.height - self.bottomView.vHeight - tmp - (tmp > 0 ? 0 : self.safeareaBottom)
                
                if tmp == 0 {
                    self.animtp = 0
                } else {
                    self.animtp = 1
                }
            } else {
                self.originY =  self.selfY - tmp + (tmp > 0 ? self.safeareaBottom : 0)
            }
            
            self.layoutIfNeeded()
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
        
//        sendButton.originY -= range * 0.5
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
            textView.text = placeHolder
            textView.textColor = placeHoderColor
        }
    }
}

public extension IMChatView {
    /**
     清除历史记录
     */
    func cleanHistory() {
        messageTable.cleanHistory()
    }
    
    /**
     断开连接
     */
    func disconnect() {
        messageTable.disconnect()
    }
    
    
    /**
     配置连接
     - parameters:
        - config: 配置信息
        - onSuccess: 连接成功回调
        - onFailer: 连接失败回调
     */
    func buildConnection(config: UnifyDataConfig, onSuccess: (() -> Void)? = nil, onFailer: (() -> Void)? = nil) {
        completeAction = onSuccess
        messageTable.errorAction = onFailer
        messageTable.build(config: config)
    }
    
    /**
     配置UI信息
     - parameters:
        - config: UI配置
     */
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
        
        if let send = config.sendTextColor {
            messageTable.setSendColor(color: send)
        }
        
        if let receive = config.receiveTextColor {
            messageTable.setReceiveColor(color: receive)
        }
        
        if let color = config.timeTextColor {
            messageTable.setTimeColor(color: color)
        }
        
        if let text = config.buttonText {
            sendButton.setTitle(text, for: .normal)
        }
        
        if let text = config.placeHolderText {
            placeHolder = text
            textView.text = text
        }
        
        if let lottie = config.loadingLottie {
            messageTable.setLottie(lottie: lottie)
        }
        
        if let view = self.parentViewController {
            parentController = view
            
        }
    }
}

extension IMChatView {
    @objc func showImage(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let url = dict["url"] as? String, let size = dict["size"] as? CGSize, let rect = dict["setAbel"] as? CGRect {
                imgFrame = messageTable.getCellRectFromSuperView(rect)
                imgFrame = self.convert(imgFrame, to: self.superview)
                
                alertImg = UIImageView()
                alertImg.kf.setImage(with: URL(string: url))
                if alertImg.image == nil { return }
                
                bgHover = UIView()
                parentController.view.addSubview(bgHover)
                bgHover.backgroundColor = .black
                bgHover.frame = CGRect(x: 0, y: 0, width: parentController.view.vWidth, height: parentController.view.vHeight)
                bgHover.alpha = 0
                
                showScroll = ImageScrollView()
                parentController.view.addSubview(showScroll)
                
                showScroll.alpha = 0
                showScroll.translatesAutoresizingMaskIntoConstraints = false
                showScroll.leftAnchor.constraint(equalTo: parentController.view.leftAnchor).isActive = true
                showScroll.rightAnchor.constraint(equalTo: parentController.view.rightAnchor).isActive = true
                showScroll.topAnchor.constraint(equalTo: parentController.view.topAnchor).isActive = true
                showScroll.bottomAnchor.constraint(equalTo: parentController.view.bottomAnchor).isActive = true
                showScroll.layoutIfNeeded()
                
                showScroll.setup()
                showScroll.imageContentMode = .aspectFit
                showScroll.initialOffset = .center
                showScroll.display(img: alertImg.image, imgsize: alertImg.image?.size)
                
                showScroll.isUserInteractionEnabled = true
                showScroll.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss)))

                UIView.animate(withDuration: 0.2, animations: {
//                    self.alertImg.frame = CGRect(x: 0, y: (parHei - bigHei) * 0.5, width: bigWid, height: bigHei)
                    self.bgHover.alpha = 1
                    self.showScroll.alpha = 1
                }, completion: { value in
//                    self.alertImg.isUserInteractionEnabled = true
//                    self.alertImg.removeFromSuperview()
                    self.showScroll.isHidden = false
                })
            }
        }
    }
    
    @objc func showVideo(_ notification: NSNotification) {
        if let dict = notification.userInfo as NSDictionary? {
            if let url = dict["url"] as? String, let parentVC = self.parentViewController {
                let videoURL = URL(string: url)
                let player = AVPlayer(url: videoURL!)
                let playerViewController = AVPlayerViewController()
                playerViewController.player = player
                parentVC.present(playerViewController, animated: true) {
                    playerViewController.player!.play()
                }
            }
        }
    }
    
    @objc func dismiss() {
        UIView.animate(withDuration: 0.3, animations: {
            let framex = self.parentController.view.convert(self.imgFrame, to: self.showScroll)
            self.alertImg.frame = framex
            self.bgHover.alpha = 0
            self.showScroll.alpha = 0
        }, completion: { value in
            if value {
//                self.showScroll.contentSize = CGSize(width: 0, height: 0)
//                self.alertImg.removeFromSuperview()
                self.bgHover.removeFromSuperview()
                self.showScroll.removeFromSuperview()
            }
        })
    }
}

extension IMChatView: ImagePickerDelegate {
    public func didSelect(image: UIImage?) {
        
    }
}
