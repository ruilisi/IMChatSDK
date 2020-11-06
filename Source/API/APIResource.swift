//
//  APIResource.swift
//  IMChatSDK
//
//  Created by Linti on 2020/11/5.
//

import Foundation
import SwiftyJSON

class APIResource {
    let raw: JSON?

    required init(raw: JSON?) {
        self.raw = raw
    }
}

