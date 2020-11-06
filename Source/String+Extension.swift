extension String {
    subscript (index: Int) -> String{
        let startIndex = self.index(self.startIndex, offsetBy: index)
        let endIndex = self.index(startIndex, offsetBy: 1)
        return String(self[startIndex..<endIndex])
    }
    
    var webSocketURL: String {
        var url = self.replacingOccurrences(of: "https://", with: "wss://")
        url += "/websocket"
        return url
    }
    
    static func random(_ length: Int = 20) -> String {
        let base = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        var randomString: String = ""

        for _ in 0..<length {
            let randomValue = Int(arc4random_uniform(UInt32(base.count)))
            randomString.append(base[base.index(base.startIndex, offsetBy: randomValue)])
        }

        return randomString
    }
}
