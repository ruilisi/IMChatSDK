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
        
        if #available(iOS 11.0, *) {
            if let window = UIApplication.shared.keyWindow {
                safeAreaTop = window.safeAreaInsets.top
                safeAreaBottom = window.safeAreaInsets.bottom
            }
        }
        
        view.backgroundColor = .gray
        
        chatView = IMChatView(frame: CGRect(x: 0, y: 20, width: screenWidth, height: screenHeight - 20))
        
        let uiConfig = UnifyUIConfig()
            .setBGColor(color: .clear)
            .setTextColor(color: .white)
            .setTextBGColor(color: UIColor(hex: 0x494766))
            .setBottomColor(color: UIColor(hex: 0x242433))
            .setButtonColor(color: UIColor(hex: 0x494766))
            .setPlaceHolderColor(color: UIColor(hex: 0x9696B5))
            .setSendBG(image: UIImage(named: "testImg"), edge: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
            .setReceiveBG(image: UIImage(named: "testImg2"), edge: UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20))
        
        chatView.buildUI(config: uiConfig)
        
        view.addSubview(chatView)
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        self.showSpinner(onView: self.view)
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
            .setApiKey(key: "f6e873f72d5a465fae785d6143adb985")
            .setDepartmentID(did: "369d2d2b-f68b-4cf3-ba36-c588013fc511")
            .setUserName(uname: "TestUserName")
            .setWelcome(text: "Welcom to eSheep")
            .setLoadHistoryCount(count: 10)
            .setPerLoadHistoryCount(count: 2)
            .setTimeSpan(timeinterval: 200)
        
        self.chatView.buildConnection(config: dataconfig, onSuccess: {
            self.removeSpinner()
        }, onFailer: {
            self.alertMessage(title: "连接失败")
        })
    }
    
    func alertMessage(title: String? = nil, message: String? = nil) {
        let controller = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(okAction)
        present(controller, animated: true, completion: nil)
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

