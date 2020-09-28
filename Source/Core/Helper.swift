//
//  Helper.swift
//  IMChatSDK
//
//  Created by 徐文杰 on 2020/9/28.
//

import Foundation
class Helper {
    
    // MARK: - 随机生成ID
    static func createID(_ seed: String = unmistakableChars) -> String {
        let count = seed.count
        var result = ""
        for _ in 0 ..< 17 {
            let chart = seed[Int.random(in: 0..<count)]
            result += chart
        }
        return result
    }
}
