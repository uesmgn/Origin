//
//  TableViewCell.swift
//  Origin
//
//  Created by Gen on 2016/11/27.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit

extension UITableViewCell {
    
    @IBInspectable
    var selectedBackgroundColor: UIColor? {
        get {
            return selectedBackgroundView?.backgroundColor
        }
        set(color) {
            let background = UIView()
            background.backgroundColor = color
            selectedBackgroundView = background
        }
    }
}
