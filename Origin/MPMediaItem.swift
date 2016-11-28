//
//  MPMediaItem.swift
//  Origin
//
//  Created by Gen on 2016/11/27.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import MediaPlayer
import UIKit

private var indexPathKey: UInt8 = 0

extension MPMediaItem {
    
    public var isKnown: NSIndexPath? {
        
        get {
            return objc_getAssociatedObject(self, &indexPathKey) as? NSIndexPath
        }
        
        set {
            objc_setAssociatedObject(self, &indexPathKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
    }
    
}
