//
//  IMChatSDK.swift
//  IMChatSDK
//
//  Created by 徐文杰 on 2020/9/15.
//

import Foundation


fileprivate class ThisClass {}

public struct Resources {
    public static var bundle: Bundle {
        let path = Bundle(for: ThisClass.self).resourcePath! + "/IMChatSDK.bundle"
        return Bundle(path: path)!
    }
}

internal struct WrappedBundleImage: _ExpressibleByImageLiteral {
    let image: UIImage?

    init(imageLiteralResourceName name: String) {
        image = UIImage(named: name, in: Resources.bundle, compatibleWith: nil)
    }
}

extension UIImage {
    static func fromWrappedBundleImage(_ wrappedImage: WrappedBundleImage) -> UIImage? {
        return wrappedImage.image
    }
}
