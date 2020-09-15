//
//  ViewController.swift
//  IMChatSDK
//
//  Created by Thisismy0312 on 09/15/2020.
//  Copyright (c) 2020 Thisismy0312. All rights reserved.
//

import UIKit
import IMChatSDK

class ViewController: UIViewController {
    var vSpinner: UIView?
    var chatView = IMChatView()
    
    var safeAreaTop: CGFloat = 20
    var safeAreaBottom: CGFloat = 0
    var toppading: CGFloat = 0
    
    var didDisapper = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "客服聊天"
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow {
                safeAreaTop = window.safeAreaInsets.top
                safeAreaBottom = window.safeAreaInsets.bottom
            }
        }
        let gradientLayer = CAGradientLayer.init()
        gradientLayer.frame = CGRect(x: 0, y: 0, width: screenWidth, height: screenHeight)
        gradientLayer.colors = [UIColor(red: 34.color, green: 31.color, blue: 51.color, alpha: 1).cgColor, UIColor(red: 10.color, green: 10.color, blue: 26.color, alpha: 1).cgColor]
        gradientLayer.locations = [0.5, 1]
        gradientLayer.startPoint = CGPoint.init(x: 1, y: 0)
        gradientLayer.endPoint = CGPoint.init(x: 1, y: 1)
        view.layer.addSublayer(gradientLayer)
        
        chatView = IMChatView(frame: CGRect(x: 0, y: 20, width: screenWidth, height: screenHeight - 20))
        
        let uiConfig = UnifyUIConfig()
            .setBGColor(color: .clear)
            .setTextColor(color: .white)
            .setTextBGColor(color: UIColor(hex: 0x494766))
            .setBottomColor(color: UIColor(hex: 0x242433))
            .setButtonColor(color: UIColor(hex: 0x494766))
            .setPlaceHolderColor(color: UIColor(hex: 0x9696B5))
        
        self.chatView.buildUI(config: uiConfig)
        
        view.addSubview(chatView)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.showSpinner(onView: self.view)
        chatView.cleanHistory()
        requestService()
        didDisapper = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        didDisapper = true
        chatView.cleanHistory()
        chatView.disconnect()
        removeSpinner()
    }
}

extension ViewController {
    func requestService() {
        let url = "wss://chat.esheeps.com/websocket"
        
        let dataconfig = UnifyDataConfig()
            .setUrl(url: url)
            .setRoomID(rid: "WjEe8fuy7tv3c33wvaYZNyFk9YAkvx5gSX")
            .setUserID(uid: "aYZNyFk9YAkvx5gSX")
            .setToken(token: "bJMFJEWqUPym2BjDPHWRarL6qgQ6EBRM-jKScr5Hmie")
            .setWelcome(text: "你好")
            .setPreLoadHistoryCount(count: 10)
        
        self.chatView.buildConnection(config: dataconfig)
        
        self.chatView.completeAction = {
            self.removeSpinner()
        }
    }
}

extension ViewController {
    func showSpinner(onView: UIView) {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.1)
        let loadView = UIActivityIndicatorView.init(style: .whiteLarge)
        loadView.startAnimating()
        loadView.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(loadView)
            onView.addSubview(spinnerView)
        }
        vSpinner = spinnerView
    }
    
    func removeSpinner() {
        
        if vSpinner == nil { return }
        
        DispatchQueue.main.async {
            self.vSpinner?.removeFromSuperview()
            self.vSpinner = nil
        }
    }
}

extension Int {
    var flo: CGFloat {
        return CGFloat(self)
    }
    
    var color: CGFloat {
        return self.flo / 225.0
    }
}

extension UIColor {
    
    convenience init(hex:Int, alpha:CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }
    
}

