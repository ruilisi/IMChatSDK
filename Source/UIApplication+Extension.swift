//
//  UIApplicationExtension.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/9/10.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import Foundation

// MARK: - Status Bar View
extension UIApplication {
    public var statusBarView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 38482
            let keyWindow = UIApplication.shared.windows.filter { $0.isKeyWindow }.first

            if let statusBar = keyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                guard let statusBarFrame = keyWindow?.windowScene?.statusBarManager?.statusBarFrame else { return nil }
                let statusBarView = UIView(frame: statusBarFrame)
                statusBarView.tag = tag
                keyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        } else {
            return nil
        }
    }
}
