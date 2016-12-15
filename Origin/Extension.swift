//
//  Extension.swift
//  Origin
//
//  Created by Gen on 2016/12/07.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(hex:Int, alpha:CGFloat = 1.0) {
        self.init(
            red:   CGFloat((hex & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hex & 0x00FF00) >> 8)  / 255.0,
            blue:  CGFloat((hex & 0x0000FF) >> 0)  / 255.0,
            alpha: alpha
        )
    }
}

extension UIView {
    
    func rotate(_ toValue: CGFloat, duration: CFTimeInterval = 0.2) {
        let animation = CABasicAnimation(keyPath: "transform.rotation")
        
        animation.toValue = toValue
        animation.duration = duration
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        
        self.layer.add(animation, forKey: nil)
    }
    
}

extension Array {
    mutating func shuffle () {
        for i in (0..<self.count).reversed() {
            let ix1 = i
            let ix2 = Int(arc4random_uniform(UInt32(i+1)))
            (self[ix1], self[ix2]) = (self[ix2], self[ix1])
        }
    }
}

extension UIButton {
    
    enum image: String {
        case on = "success"
        case off = "off"
    }
    
    func know() {
        self.imageView?.image = UIImage(named: image.on.rawValue)
        self.isKnown = true
    }
    
    func unknown() {
        self.imageView?.image = UIImage(named: image.off.rawValue)
        self.isKnown = false
    }
    
    var isKnown:Bool {
        get {
            return self.isKnown
        }
        set{ }
    }
}
