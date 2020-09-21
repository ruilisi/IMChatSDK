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
}
