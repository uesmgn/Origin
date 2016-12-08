//
//  SectionHeader.swift
//  Origin
//
//  Created by Gen on 2016/12/07.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit

protocol SectionHeaderDelegate {
    func toggleSection(_ header: SectionHeader, section: Int)
}

class SectionHeader: UITableViewHeaderFooterView {
    
    var delegate: SectionHeaderDelegate?
    var section: Int = 0
    
    let titleLabel = UILabel()
    let arrowLabel = UILabel()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        
        //
        // Constraint the size of arrow label for auto layout
        //
        arrowLabel.widthAnchor.constraint(equalToConstant: 12).isActive = true
        arrowLabel.heightAnchor.constraint(equalToConstant: 12).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        arrowLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(arrowLabel)
        //
        // Call tapHeader when tapping on this header
        //
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(SectionHeader.tapHeader(_:))))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let label = UILabel()
        label.font = UIFont(name: "HelveticaNeue", size: 12)
        
        contentView.backgroundColor = UIColor(hex: 0x2E3944)
        titleLabel.font = label.font
        arrowLabel.font = label.font
        titleLabel.textColor = UIColor.lightGray
        arrowLabel.textColor = UIColor.lightGray
        //
        // Autolayout the lables
        //
        let views = [
            "titleLabel" : titleLabel,
            "arrowLabel" : arrowLabel,
            ]
        
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "H:|-20-[titleLabel]-[arrowLabel]-20-|",
            options: [],
            metrics: nil,
            views: views
        ))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[titleLabel]-|",
            options: [],
            metrics: nil,
            views: views
        ))
        
        contentView.addConstraints(NSLayoutConstraint.constraints(
            withVisualFormat: "V:|-[arrowLabel]-|",
            options: [],
            metrics: nil,
            views: views
        ))
    }
    
    //
    // Trigger toggle section when tapping on the header
    //
    func tapHeader(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let cell = gestureRecognizer.view as? SectionHeader else {
            return
        }
        
        delegate?.toggleSection(self, section: cell.section)
    }
    
    func setCollapsed(_ collapsed: Bool) {
        //
        // Animate the arrow rotation (see Extensions.swf)
        //
        arrowLabel.rotate(collapsed ? 0.0 : CGFloat(M_PI_2))
    }
    
}
