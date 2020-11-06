//
//  UIImage+Extension.swift
//  IMChatSDK
//
//  Created by Linti on 2020/11/5.
//

import Foundation
import UIKit

extension UIImage {
    
    func resized(withPercentage percentage: CGFloat) -> UIImage? {
        if percentage == 1.0 { return self }

        let canvasSize = CGSize(width: size.width * percentage, height: size.height * percentage)
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: canvasSize))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
//    var compressedForUpload: Data {
//        guard let auth = AuthManager.isAuthenticated() else { return Data() }
//        guard let settings = auth.settings else { return Data() }
//        let maxSize = settings.maxFileSize
//        return compressedImage(forMaxExpectedSize: maxSize)
//    }
    
    var compressedForUpload: Data {
        if let pngData = self.pngData() {
            return pngData
        }
        
        if let jpgData = self.jpegData(compressionQuality: 0.7) {
            return jpgData
        }
        
        return Data()
    }
    
    func compressedImage(forMaxExpectedSize maxSize: Int) -> Data {

        let jpegImage = self.jpegData(compressionQuality: 1.0) ?? Data()
        let imageSize = jpegImage.byteSize

        if imageSize < maxSize || maxSize <= 0 {
            return jpegImage
        }

        var percentSize = UIImage.percentSizeAfterCompression(forImageWithSize: imageSize, maxExpectedSize: maxSize)
        while true {
            let compressedImage = self.compressedImage(resizedWithPercentage: percentSize)
            if compressedImage.byteSize < maxSize || percentSize == 0.0 {
                return compressedImage
            } else if percentSize < 0.1 {
                percentSize = 0.0
            } else {
                percentSize *= 0.8
            }
        }
    }

    private func compressedImage(resizedWithPercentage percentage: CGFloat) -> Data {
        let resizedImage = self.resized(withPercentage: percentage) ?? UIImage()
        return resizedImage.jpegData(compressionQuality: 0.5) ?? Data()
    }
    
    private static func percentSizeAfterCompression(forImageWithSize size: Int, maxExpectedSize maxSize: Int) -> CGFloat {
        let sizeReductionFactor: CGFloat = 0.36
        let safeEstimationFactor: CGFloat = 0.95

        let expectedImageSizeOnCompression = CGFloat(size) * sizeReductionFactor
        if expectedImageSizeOnCompression < CGFloat(maxSize) {
            return 1.0
        } else {
            return safeEstimationFactor * CGFloat(maxSize) / expectedImageSizeOnCompression
        }
    }
}
