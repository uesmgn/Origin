//
//  MiniPlayerView.swift
//  Origin
//
//  Created by Gen on 2016/11/24.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit

class MiniPlayerView: UIView {
    
    override func draw(_ rect: CGRect) {
        let topLine = UIBezierPath(rect: CGRect(x: 0, y: 0, width: self.frame.size.width, height: 0.5))
        UIColor.gray.setStroke()
        topLine.lineWidth = 0.2
        topLine.stroke()
        
        let bottomLine = UIBezierPath(rect: CGRect(x: 0, y: self.frame.size.height - 0.5, width: self.frame.size.width, height: 0.5))
        UIColor.lightGray.setStroke()
        bottomLine.lineWidth = 0.2
        bottomLine.stroke()
    }

}
