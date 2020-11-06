public let screenSize = UIScreen.main.bounds
public let screenWidth = screenSize.width
public let screenHeight = screenSize.height
public let unmistakableChars
 = "23456789ABCDEFGHJKLMNPQRSTWXYZabcdefghijkmnopqrstuvwxyz"

public let timeNow = Int(Date().timeIntervalSince1970) * 1000
public var pingCount = 0
public var globalDataConfig: UnifyDataConfig = UnifyDataConfig()

struct FileUpload {
    var name: String
    var size: Int
    var type: String
    var data: Data
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case head = "HEAD"
    case delete = "DELETE"
    case patch = "PATCH"
    case trace = "TRACE"
    case options = "OPTIONS"
    case connect = "CONNECT"
}
