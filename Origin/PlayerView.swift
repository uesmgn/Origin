//
//  PlayerView.swift
//  Origin
//
//  Created by Gen on 2017/01/10.
//  Copyright © 2017年 Gen. All rights reserved.
//

import Foundation
import UIKit
import Spring
import Cosmos
import MarqueeLabel
import KDEAudioPlayer
import Foundation

@IBDesignable class PlayerView: UIView, XibInstantiatable {

    @IBOutlet weak var labelFrame: UIButton!
    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var detailLabel: MarqueeLabel!
    @IBOutlet weak var showPlaylistButton: UIButton!
    @IBOutlet weak var modeButton: UIButton!
    @IBOutlet weak var toggleButton: SpringButton!
    @IBOutlet weak var nextButton: SpringButton!
    @IBOutlet weak var backButton: SpringButton!
    @IBOutlet weak var knownButton: SpringButton!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var controller: UIView!
    @IBOutlet weak var playlist: PlaylistView!

    let shared = AudioManager.shared
    var player: AudioPlayer?

    // メタデータを表示している曲
    var currentItem: AudioItem? {
        didSet {
            guard currentItem != nil else {
                self.isHidden = true
                return
            }
            self.isHidden = false
        }
    }

    var playlistOpen: Bool = false {
        didSet {
            self.playlist.isHidden = !playlistOpen
            self.controller.isHidden = playlistOpen
        }
    }

    open var didFinishRating: ((Double) -> Void)?
    open var didChangeKnown: ((Bool) -> Void)?

    override func awakeFromNib() {
        instantiate()
        shared.controll = self
        player = shared.player
        self.ratingView.didFinishTouchingCosmos = didFinishTouchingCosmos
        self.isHidden = true
        self.updateMetadata()
        self.playlistOpen = false
    }

    private func didFinishTouchingCosmos(_ rating: Double) {
        self.currentItem?.rating = Int(rating)
        self.currentItem?.saveRating(rating)
        didFinishRating?(rating)
    }

    // コードから初期化
    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiate()
    }

    // storyboardから初期化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiate()
    }

    // UI
    open var rating: Double = 0 {
        didSet { self.ratingView.rating = rating }
    }

    open var state: AudioPlayerState = .stopped {
        didSet { changeState(self.state) }
    }

    open var mode: AudioPlayerMode = .repeatAll {
        didSet { changeMode(self.mode) }
    }

    open var isKnown: Bool = false {
        didSet { changeKnown(isKnown) }
    }

    func changeState(_ state: AudioPlayerState) {
        DispatchQueue.main.async {
            switch (state) {
            case .playing:
                self.toggleButton.imageView?.image = UIImage(image: .Player_pause)
            case .paused:
                self.toggleButton.imageView?.image = UIImage(image: .Player_play)
            case .buffering:
                self.toggleButton.imageView?.image = UIImage(image: .Player_play)
            default: break
            }
        }
    }

    func changeMode(_ mode: AudioPlayerMode) {
        DispatchQueue.main.async {
            switch (mode) {
            case AudioPlayerMode.normal:
                fallthrough
            case AudioPlayerMode.shuffle:
                self.modeButton.imageView?.image = UIImage(image: .Shuffle)
            case AudioPlayerMode.repeat:
                self.modeButton.imageView?.image = UIImage(image: .Repeat)
            case AudioPlayerMode.repeatAll:
                self.modeButton.imageView?.image = UIImage(image: .Stream)
            default: break
            }
        }
    }

    func changeKnown(_ flag: Bool) {
        DispatchQueue.main.async {
            if flag {
                self.knownButton.imageView?.image = UIImage(image: .Known)
            } else {
                self.knownButton.imageView?.image = UIImage(image: .Unknown)
            }
        }
    }

    func updateMetadata() {
        guard let item = self.currentItem else {
            return
        }
        self.titleLabel.text = item.title ?? "---"
        if let artist = item.artist, let album = item.album {
            self.detailLabel.text = artist+" - "+album
        } else {
            self.detailLabel.text = "---"
        }
        self.isKnown = item.isKnown
        self.rating = Double(item.rating)
        self.mode = player?.mode ?? .shuffle
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateplaylist"), object: nil)
    }
    @IBAction func onModeButton(_ sender: Any) {
        guard let player = self.player else { return }
        shared.modeSwitch()
        self.mode = player.mode
    }

    @IBAction func onKnownButton(_ sender: Any) {
        self.isKnown = !self.isKnown
        didChangeKnown?(self.isKnown)
        self.currentItem?.isKnown = isKnown
        self.currentItem?.saveKnown(isKnown)
        self.knownButton.pop()
    }

    @IBAction func showPlaylist(_ sender: Any) {
        playlistOpen = !playlistOpen
    }

    @IBAction func onToggleButton(_ sender: Any) {
        guard let player = self.player else { return }
        switch (player.state) {
        case .playing:
            player.pause()
            self.state = .paused
        case .paused:
            if player.currentItem != nil {
                player.resume()
                self.state = .playing
            }
        default: break
        }
        self.toggleButton.pop()

    }

    @IBAction func onNextButton(_ sender: Any) {
        guard let player = self.player else { return }
        player.next()
        self.nextButton.pop()
    }

    @IBAction func onBackButton(_ sender: Any) {
        guard let player = self.player else { return }
        player.previous()
        self.backButton.pop()
    }
}
