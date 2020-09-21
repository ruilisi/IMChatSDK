//
//  MessageTableViewCell.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/8/28.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import UIKit
import Lottie

class MessageTableViewCell: UITableViewCell {

    let label = UILabel()
    let time = UILabel()
    let bgimage = UIImageView()
    let loadingLottie = AnimationView(name: "msgloading", bundle: Resources.bundle, imageProvider: nil, animationCache: nil)
    
    var timeInt = Int()
    var messageID = String()
    
    let windowSize = UIScreen.main.bounds
    let windowWidth = screenSize.width

    var sendBG = UIImage(named: "bgSend", in: Resources.bundle, compatibleWith: nil)
    var receiveBG = UIImage(named: "bgReceive", in: Resources.bundle, compatibleWith: nil)
    
    var sendEdge = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    var receiveEdge = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    var rowHeight = CGFloat()
    
    private var hideTime: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(bgimage)
        addSubview(label)
        addSubview(loadingLottie)
        loadingLottie.isHidden = true
        loadingLottie.loopMode = .loop
        loadingLottie.backgroundBehavior = .pauseAndRestore
        
        selectionStyle = .none
        
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        time.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        time.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    }
    
    func setSendImg(image: UIImage, edge: UIEdgeInsets) {
        sendBG = image
        sendEdge = edge
    }
    
    func setReceivImg(image: UIImage, edge: UIEdgeInsets) {
        receiveBG = image
        receiveEdge = edge
    }
    
    // MARK: - Set Content
    func setContent(msgID: String, name: String, message: String, timeInterval: TimeInterval, isSelf: Bool = false, ishideTime: Bool = false) {
        messageID = msgID
        timeInt = Int(timeInterval)
        label.text = "\(message)"
        
        label.frame = getLabelSize(text: message, attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)], textWidth: Int(windowWidth * 0.6))
        label.numberOfLines = 0
        
        let labelWidth = label.frame.width
        let labelHeight = label.frame.height
        var timebottom: CGFloat = 0
        
        let bgWidth = labelWidth + 40
        let bgHeight = CGFloat.maximum(labelHeight + 24, 44)
        
        print("size of :\"\(message)\" is : Width \(labelWidth) Height: \(labelHeight)")
        
        hideTime = ishideTime
        
        if !ishideTime {
            addSubview(time)
            time.text = getTimeStringByCurrentDate(timeInterval: timeInterval)
            time.frame = CGRect(x: 0, y: 0, width: windowWidth, height: 15)
            time.textAlignment = .center
            timebottom = 17
        }
        
        if !isSelf {
            bgimage.image = receiveBG?.resizableImage(withCapInsets: receiveEdge, resizingMode: .stretch)
            
            bgimage.frame = CGRect(x: 10, y: timebottom, width: bgWidth, height: bgHeight)
            label.frame = CGRect(x: 30, y: (bgimage.bounds.height - labelHeight) * 0.5 + timebottom, width: labelWidth, height: labelHeight)
            rowHeight = bgimage.bottom + 20.0
        } else {
            bgimage.image = sendBG?.resizableImage(withCapInsets: sendEdge, resizingMode: .stretch)
            
            bgimage.frame = CGRect(x: windowWidth - bgWidth - 10, y: timebottom, width: bgWidth, height: bgHeight)
            label.frame = CGRect(x: bgimage.frame.origin.x + 20, y: (bgimage.bounds.height - labelHeight) * 0.5 + timebottom, width: labelWidth, height: labelHeight)
            rowHeight = bgimage.bottom + 20.0
            
            loadingLottie.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraints([
                .init(item: loadingLottie, attribute: .trailing, relatedBy: .equal, toItem: bgimage, attribute: .leading, multiplier: 1, constant: -10),
                .init(item: loadingLottie, attribute: .bottom, relatedBy: .equal, toItem: bgimage, attribute: .bottom, multiplier: 1, constant: 0),
                .init(item: loadingLottie, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25),
                .init(item: loadingLottie, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25)])
        }
    }
    
    func getTimeStringByCurrentDate(timeInterval: TimeInterval) -> String {
        
        let dateVar = Date.init(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        
        let calender = NSCalendar.current
        if calender.isDateInYesterday(dateVar) {
            dateFormatter.dateFormat = "昨天 hh:mm"
        } else if calender.isDateInToday(dateVar) {
            dateFormatter.dateFormat = "今天 hh:mm"
        } else {
            dateFormatter.dateFormat = "yyyy年MM月dd日"
        }
        
        return dateFormatter.string(from: dateVar)
    }
    
    func setLoading(isLoading: Bool = true) {
        time.isHidden = hideTime ? true : isLoading
        loadingLottie.isHidden = !isLoading
        
        if isLoading {
            loadingLottie.play()
        } else {
            loadingLottie.pause()
        }
    }
    
    private func getLabelSize(text: String, attributes: [NSAttributedString.Key: Any], textWidth: Int) -> CGRect {
        
        var size = CGRect()
        
        //设置label最大宽度
        let size2 = CGSize(width: textWidth, height: 0)
        
        size = (text as NSString).boundingRect(with: size2, options: .usesLineFragmentOrigin, attributes: attributes, context: nil)
        
        return size

    }
    
    override func systemLayoutSizeFitting(_ targetSize: CGSize) -> CGSize {
        return CGSize(width: windowWidth, height: 500)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
