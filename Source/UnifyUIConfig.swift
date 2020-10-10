//
//  UnifyUIConfig.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/9/11.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import Foundation
import Lottie

open class UnifyUIConfig {
    var backgroundColor: UIColor?
    var textColor: UIColor?
    var bottomColor: UIColor?
    var textbgColor: UIColor?
    var buttonColor: UIColor?
    var placeHolderColor: UIColor?
    var sendBG: UIImage?
    var sendEdge: UIEdgeInsets?
    var receiveBG: UIImage?
    var receiveEdge: UIEdgeInsets?
    var sendTextColor: UIColor?
    var receiveTextColor: UIColor?
    var timeTextColor: UIColor?
    var buttonText: String?
    var placeHolderText: String?
    var loadingLottie: Animation?
    
    public init() {
    }
    
    /**
     设置背景颜色
     - parameters:
        - color: 背景颜色
     */
    public func setBGColor(color: UIColor) -> UnifyUIConfig {
        backgroundColor = color
        return self
    }
    
    /**
     设置输入框文本颜色
     - parameters:
        - color: 文本颜色
     */
    public func setTextColor(color: UIColor) -> UnifyUIConfig {
        textColor = color
        return self
    }
    
    /**
     设置底部颜色
     - parameters:
        - color: 底部颜色
     */
    public func setBottomColor(color: UIColor) -> UnifyUIConfig {
        bottomColor = color
        return self
    }
    
    /**
     设置输入框背景颜色
     - parameters:
        - color: 背景颜色
     */
    public func setTextBGColor(color: UIColor) -> UnifyUIConfig {
        textbgColor = color
        return self
    }
    
    /**
     设置按钮的颜色
     - parameters:
        - color: 按钮颜色
     */
    public func setButtonColor(color: UIColor) -> UnifyUIConfig {
        buttonColor = color
        return self
    }
    
    /**
     设置占位符的颜色
     - parameters:
        - color: 文本颜色
     */
    public func setPlaceHolderColor(color: UIColor) -> UnifyUIConfig {
        placeHolderColor = color
        return self
    }
    
    /**
     设置发送消息气泡的的样式
     - parameters:
        - image: 气泡背景
        - edge: 图片拉伸边距
     */
    public func setSendBG(image: UIImage?, edge: UIEdgeInsets) -> UnifyUIConfig {
        sendBG = image
        sendEdge = edge
        return self
    }
    
    /**
     设置接收消息气泡的的样式
     - parameters:
        - image: 气泡背景
        - edge: 图片拉伸边距
     */
    public func setReceiveBG(image: UIImage?, edge: UIEdgeInsets) -> UnifyUIConfig {
        receiveBG = image
        receiveEdge = edge
        return self
    }
    
    /**
     设置发送文本的颜色
     - parameters:
        - color: 文本颜色
     */
    public func setSendTextColor(color: UIColor) -> UnifyUIConfig {
        sendTextColor = color
        return self
    }
    
    /**
     设置接收文本的颜色
     - parameters:
        - color: 文本颜色
     */
    public func setReceiveTextColor(color: UIColor) -> UnifyUIConfig {
        receiveTextColor = color
        return self
    }
    
    /**
     设置时间文本的颜色
     - parameters:
        - color: 文本颜色
     */
    public func setTimeTextColor(color: UIColor) -> UnifyUIConfig {
        timeTextColor = color
        return self
    }
    
    /**
     设置发送按钮文字
     - parameters:
        - text: 按钮文字
     */
    public func setButtonText(text: String) -> UnifyUIConfig {
        buttonText = text
        return self
    }
    
    /**
     设置占位文字
     - parameters:
        - text: 文本内容
     */
    public func setPlaceHolderText(text: String) -> UnifyUIConfig {
        placeHolderText = text
        return self
    }
    
    /**
     设置载入Lottie
     - parameters:
        - lottie: 动画
     */
    public func setLoadingLottie(lottie: String) -> UnifyUIConfig {
        loadingLottie = Animation.named(lottie)
        return self
    }
}
