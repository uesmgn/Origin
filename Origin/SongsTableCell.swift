//
//  SongsTableCell.swift
//  Origin
//
//  Created by Gen on 2017/01/10.
//  Copyright © 2017年 Gen. All rights reserved.
//

import UIKit
import AudioIndicatorBars
import KDEAudioPlayer
import SDWebImage

class SongsTableCell: UITableViewCell {

    @IBOutlet weak var artwork: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var detail: UILabel!
    @IBOutlet weak var indicator: AudioIndicatorBarsView!

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var spaceView: UIView!

    var item: AudioItem?

    var currentItem: AudioItem?

    var artworkImage: UIImage?
    let defaultImage = UIImage(named: "artwork_default")!
    var imageUrl: URL?

    let player = AudioManager.shared.player

    func set(item: AudioItem) {
        self.item = item
        updateView()
        updateIndicator()
    }

    private func updateView() {
        self.artwork.isHidden = !loadCellImage
        self.spaceView.isHidden = loadCellImage

        self.title.text = item?.title ?? "unknown"
        self.detail.text = item?.artist ?? "unknown"
        self.containerView.isHidden = true
        if loadCellImage && !self.artwork.isHidden {
            if let url = item?.artworkUrl {
                self.imageUrl = URL(string: url)
                self.artwork.sd_setImage(with: self.imageUrl, placeholderImage
                    :defaultImage)
            } else {
                DispatchQueue.main.async {
                    self.artwork.image = self.item?.artworkImage ?? self.defaultImage
                }
            }
        }

    }

    func updateIndicator() {
        DispatchQueue.main.async {
            guard let i1 = self.item, let i2 = self.currentItem, i1 == i2 else {
                self.containerView.isHidden = true
                return
            }
            self.containerView.isHidden = false
            switch (self.player.state) {
            case .playing:
                self.indicator.start()
            case .paused, .buffering:
                self.indicator.stop()
            default:
                self.indicator.stop()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
