//
//  ImageZoomView.swift
//  IMChatSDK
//
//  Created by 徐文杰 on 2020/10/23.
//

import UIKit

class ImageZoomView: UIScrollView {
    var imageView: UIImageView!
    
    convenience init(frame: CGRect, image: UIImage) {
        self.init(frame: frame)
        
        self.minimumZoomScale = 1.0
        self.maximumZoomScale = 6.0
        // Creates the image view and adds it as a subview to the scroll view
        imageView = UIImageView(image: image)
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFill
        addSubview(imageView)
    }
}
