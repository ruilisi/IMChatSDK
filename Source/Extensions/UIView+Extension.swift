
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
    
    var parentViewController: UIViewController? {
        var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder?.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}


extension UITableView {
    /**
     Method to use whenever new items should be inserted at the top of the table view.
     The table view maintains its scroll position using this method.
     - warning: Make sure your data model contains the correct count of items before invoking this method.
     - parameter itemCount: The count of items that should be added at the top of the table view.
     - note: Works with `UITableViewAutomaticDimension`.
     - links: https://bluelemonbits.com/2018/08/26/inserting-cells-at-the-top-of-a-uitableview-with-no-scrolling/
     */
    func insertItemsAtTopWithFixedPosition(_ itemCount: Int) {
        layoutIfNeeded() // makes sure layout is set correctly.
        var initialContentOffSet = contentOffset.y

        // If offset is less than 0 due to refresh up gesture, assume 0.
        if initialContentOffSet < 0 {
            initialContentOffSet = 0
        }

        // Reload, scroll and set offset:
        reloadData()
        scrollToRow(
            at: IndexPath(row: itemCount, section: 0),
            at: .top,
            animated: false)
        contentOffset.y += initialContentOffSet
    }
}
