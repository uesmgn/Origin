//
//  CollectionViewCell.swift
//  Origin
//
//  Created by Gen on 2016/11/24.
//  Copyright © 2016年 Gen. All rights reserved.
//


import UIKit
import Cosmos
import expanding_collection

class CollectionViewCell: BasePageCollectionCell {
    
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var isKnown: UILabel!
    @IBOutlet weak var artworkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
