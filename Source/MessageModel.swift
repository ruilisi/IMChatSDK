//
//  MessageModel.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/8/28.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import Foundation
public struct MessageModel: Equatable, Codable, Hashable {
    var msgID: String = ""
    var name: String = ""
    var message: String = ""
    var timeInterval: Int = 0
    var roomID: String = ""
    var bySelf: Bool = false
}
