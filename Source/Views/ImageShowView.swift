//
//  ImageShowView.swift
//  IMChatSDK
//
//  Created by 徐文杰 on 2020/10/22.
//

import UIKit
import Kingfisher

class ImageShowView: UIView {
    
    let image = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(image)
        
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        image.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setImage(url: String, size: CGSize) {
        let wid = size.width
        let heg = size.height
        
        image.widthAnchor.constraint(equalTo: self.widthAnchor).isActive = true
        image.heightAnchor.constraint(equalTo: image.widthAnchor, multiplier: heg / wid).isActive = true
        image.kf.setImage(with: URL(string: url))
    }
}
