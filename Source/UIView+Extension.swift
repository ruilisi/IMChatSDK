
extension UIView {
    
    var originX: CGFloat {
        get {
            return self.frame.origin.x
        }
        
        set {
            self.frame = CGRect(x: newValue, y: originY, width: vWidth, height: vHeight)
        }
    }
    
    var originY: CGFloat {
        get {
            return self.frame.origin.y
        }
        
        set {
            self.frame = CGRect(x: originX, y: newValue, width: vWidth, height: vHeight)
        }
    }
    
    var vWidth: CGFloat {
        get {
            return self.frame.width
        }
        
        set {
            self.frame = CGRect(x: originX, y: originY, width: newValue, height: vHeight)
        }
    }
    
    var vHeight: CGFloat {
        get {
            return self.frame.height
        }
        
        set {
            self.frame = CGRect(x: originX, y: originY, width: vWidth, height: newValue)
        }
    }
    
    var bottom: CGFloat {
        return originY + vHeight
    }
    
    var top: CGFloat {
        return originY
    }
    
    var right: CGFloat {
        return originX + vWidth
    }
    
    var left: CGFloat {
        return originX
    }
}
