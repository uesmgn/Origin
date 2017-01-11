//
//  PlaylistCell.swift
//  Origin
//
//  Created by Gen on 2017/01/10.
//  Copyright © 2017年 Gen. All rights reserved.
//

import UIKit
import KDEAudioPlayer
import SDWebImage

class PlaylistCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    var item: AudioItem?
    var IndexPath: IndexPath?

    var artworkImage: UIImage?
    let defaultImage = UIImage(named: "artwork_default")!
    var imageUrl: URL?

    let player = AudioManager.shared.player

    func set(item: AudioItem) {
        self.item = item
        if loadPlaylistImage {
            DispatchQueue.main.async {
                self.loadImage()
            }
        }
    }

    private func loadImage() {
        if let url = item?.artworkUrl {
            self.imageUrl = URL(string: url)
            self.imageView.sd_setImage(with: self.imageUrl, placeholderImage: defaultImage)
        } else {
            self.imageView.image = self.item?.artworkImage ?? nil
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        imageView.layer.cornerRadius = 4.0
        imageView.layer.masksToBounds = true
    }

}
