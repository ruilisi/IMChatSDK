//
//  MessageTableViewCell.swift
//  eSheep
//
//  Created by 徐文杰 on 2020/8/28.
//  Copyright © 2020 Mauricio Cousillas. All rights reserved.
//

import UIKit
import Lottie
import Kingfisher

enum CellType {
    case Text
    case Image
    case Video
    case File
}

class MessageTableViewCell: UITableViewCell {

    let label = UILabel()
    let time = UILabel()
    let bgimage = UIImageView()
    let cellImage = UIImageView()
    var anim: Animation? = nil
//    let loadingLottie = AnimationView(name: "msgloading", bundle: Resources.bundle, imageProvider: nil, animationCache: nil)
    let loadingLottie = AnimationView()
    
    var timeInt = Int()
    var messageID = String()
    
    let windowSize = UIScreen.main.bounds
    let windowWidth = screenSize.width
    let windowHeight = screenSize.height

    var sendBG = UIImage(named: "bgSend", in: Resources.bundle, compatibleWith: nil)
    var receiveBG = UIImage(named: "bgReceive", in: Resources.bundle, compatibleWith: nil)
    
    var sendEdge = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    var receiveEdge = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
    
    var receiveColor: UIColor = .white
    var sendColor: UIColor = .white
    
    var timeColor: UIColor = .white
    
    var urlHead = String()
    var rowHeight = CGFloat()
    var imageUrl = String()
    var videoUrl = String()
    var imageSize = CGSize()
    var model: MessageModel?
    
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
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        time.alpha = 0.5
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
    func setContent(baseUrl: String, messageContent: MessageModel, ishideTime: Bool = false) {
        
        let msgID = messageContent.msgID
        let message = messageContent.message
        let timeInterval = TimeInterval(messageContent.timeInterval / 1000)
        model = messageContent
        urlHead = baseUrl
        
        messageID = msgID
        timeInt = Int(timeInterval)
        label.text = message
        label.numberOfLines = 0
        
        if let lottie = anim {
            loadingLottie.animation = lottie
        } else {
            loadingLottie.animation = Animation.named("msgloading", bundle: Resources.bundle, subdirectory: nil, animationCache: nil)
        }
        
        hideTime = ishideTime
        
        if !ishideTime {
            addSubview(time)
            time.textColor = timeColor
            time.text = getTimeStringByCurrentDate(timeInterval: timeInterval)
            time.translatesAutoresizingMaskIntoConstraints = false
            time.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            time.topAnchor.constraint(equalTo: self.topAnchor, constant: 10).isActive = true
            time.layoutIfNeeded()
        }
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: bgimage.centerYAnchor).isActive = true
        label.centerXAnchor.constraint(equalTo: bgimage.centerXAnchor).isActive = true
        
        if label.intrinsicContentSize.width > windowWidth * 0.6 {
            label.widthAnchor.constraint(equalToConstant: windowWidth * 0.6).isActive = true
        }
        
        label.layoutIfNeeded()
        
        bgimage.translatesAutoresizingMaskIntoConstraints = false
        
        var cellType: CellType = .Text
        
//        if let imgUrl = messageContent.imageUrl, !imgUrl.isEmpty { cellType = .Image }
//        if let imgUrl = messageContent.imageUrl, !imgUrl.isEmpty { cellType = .Image }
         
        let type = messageContent.fileType ?? ""
        if type.contains("video") {
            cellType = .Video
        } else if type.contains("image") {
            cellType = .Image
        } else {
            cellType = .Text
        }
        
        switch cellType {
        case .Text:
            setTextContent(messageContent: messageContent)
        case .Image:
            setImageContent(baseUrl: baseUrl, messageContent: messageContent)
        case .Video:
            setVideoContent()
        case .File:
            setFileContent()
        }
    }
    
    func setTextContent(messageContent: MessageModel) {
        if label.frame.width + 30.0 < 50 {
            bgimage.widthAnchor.constraint(equalToConstant: 50).isActive = true
        } else {
            bgimage.widthAnchor.constraint(equalTo: label.widthAnchor, constant: 35).isActive = true
        }
        
        bgimage.heightAnchor.constraint(equalTo: label.heightAnchor, constant: 25).isActive = true
        bgimage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
        
        if !messageContent.bySelf {
            label.textColor = receiveColor
            bgimage.image = receiveBG?.resizableImage(withCapInsets: receiveEdge, resizingMode: .stretch)
            bgimage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
            
            rowHeight = bgimage.bottom + 20.0
        } else {
            label.textColor = sendColor
            bgimage.image = sendBG?.resizableImage(withCapInsets: sendEdge, resizingMode: .stretch)
            bgimage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
            
            loadingLottie.translatesAutoresizingMaskIntoConstraints = false
            self.addConstraints([
                .init(item: loadingLottie, attribute: .trailing, relatedBy: .equal, toItem: bgimage, attribute: .leading, multiplier: 1, constant: -10),
                .init(item: loadingLottie, attribute: .bottom, relatedBy: .equal, toItem: bgimage, attribute: .bottom, multiplier: 1, constant: 0),
                .init(item: loadingLottie, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25),
                .init(item: loadingLottie, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25)])
        }
        bgimage.layoutIfNeeded()
        
        rowHeight = bgimage.frame.height + time.frame.height + 30
    }
    
    func setImageContent(baseUrl: String, messageContent: MessageModel) {
        if let url = messageContent.imageUrl, let width = messageContent.imageWidth, let height = messageContent.imageHeight {
            bgimage.isHidden = true
            let imgwid = width.flo > windowWidth * 0.6 ? windowWidth * 0.6 : width.flo
            let imghei = CGFloat.maximum(CGFloat.minimum(imgwid * (height.flo / width.flo), windowHeight * 0.4), windowHeight * 0.2)
            
            addSubview(cellImage)
            cellImage.translatesAutoresizingMaskIntoConstraints = false
            cellImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
            cellImage.widthAnchor.constraint(equalToConstant: imgwid).isActive = true
            cellImage.heightAnchor.constraint(equalToConstant: imghei).isActive = true
            
            if !messageContent.bySelf {
                cellImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
            } else {
                cellImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
            }
            cellImage.layoutIfNeeded()
            cellImage.layer.cornerRadius = 5
            cellImage.layer.masksToBounds = true
            cellImage.layer.borderWidth = 1
            cellImage.layer.borderColor = UIColor(hex: 0xCCCCCC).cgColor
            cellImage.isUserInteractionEnabled = true
            cellImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageClick)))
            
            imageUrl = baseUrl + url
            imageSize = CGSize(width: width, height: height)
            
            let imageurl = URL(string: imageUrl)
            
            DispatchQueue.main.async {
                self.cellImage.kf.setImage(with: imageurl)
                self.cellImage.contentMode = .scaleAspectFill
                self.cellImage.clipsToBounds = true
            }
            
            rowHeight = cellImage.frame.height + time.frame.height + 30
        }
    }
    
    func setVideoContent() {
        if let messageContent = model, let url = messageContent.imageUrl {
            bgimage.isHidden = true
            
            let imgwid = windowWidth * 0.6
            let imghei = windowHeight * 0.3
            
            addSubview(cellImage)
            cellImage.translatesAutoresizingMaskIntoConstraints = false
            cellImage.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10).isActive = true
            cellImage.widthAnchor.constraint(equalToConstant: imgwid).isActive = true
            cellImage.heightAnchor.constraint(equalToConstant: imghei).isActive = true
            
            if !messageContent.bySelf {
                cellImage.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 10).isActive = true
            } else {
                cellImage.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -10).isActive = true
            }
            
            cellImage.layoutIfNeeded()
            cellImage.layer.cornerRadius = 5
            cellImage.layer.masksToBounds = true
            cellImage.layer.borderWidth = 1
            cellImage.layer.borderColor = UIColor(hex: 0xCCCCCC).cgColor
            cellImage.isUserInteractionEnabled = true
            cellImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(videoClick)))
            cellImage.backgroundColor = .black
            
            imageUrl = urlHead + url
            
            rowHeight = cellImage.frame.height + time.frame.height + 30
        }
    }
    
    func setFileContent() {
        
    }
    
    func getTimeStringByCurrentDate(timeInterval: TimeInterval) -> String {
        
        let dateVar = Date.init(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        
        var timeshow = ""
        
        let calender = NSCalendar.current
        dateFormatter.dateFormat = "hh:mm"
        
        if calender.isDateInYesterday(dateVar) {
            timeshow = "yesterday "
        } else if calender.isDateInToday(dateVar) {
            timeshow = "today "
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd"
        }
        
        return timeshow + dateFormatter.string(from: dateVar)
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

extension MessageTableViewCell {
    @objc func imageClick() {
        let frame = self.convert(cellImage.frame, to: self.superview)
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showImage"), object: nil, userInfo: ["url": imageUrl, "size": imageSize, "setAbel": frame])
    }
    
    @objc func videoClick() {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "showVideo"), object: nil, userInfo: ["url": imageUrl])
    }
}
