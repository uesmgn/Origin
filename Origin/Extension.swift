//
//  Extension.swift
//  Origin
//
//  Created by Gen on 2016/12/07.
//  Copyright © 2016年 Gen. All rights reserved.
//

// EDITED

import UIKit
import Spring
import AVFoundation
import RealmSwift
import KDEAudioPlayer

extension UIColor {

    convenience init(hex: Int, alpha: CGFloat = 1.0) {
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

extension UIImage {

    enum image: String {
        case Player_play = "play-2"
        case Player_pause = "pause-2"
        case Icon = "icon"
        case Shuffle = "shuffle"
        case Repeat = "repeat"
        case Stream = "stream"
        case Play = "play-1"
        case Pause = "pause-1"
        case Next = "fastforward"
        case Known = "known"
        case Unknown = "unknown"
        case Like = "like"
        case Dislike = "dislike"
        case Success = "success"
        case Question = "question"
    }

    convenience init(image: image) {
        self.init(named: image.rawValue)!
    }
}

extension NSNotification.Name {

    enum key: String {
        case Open = "origin.notification.name.open.window"
        case UpdateSongMenu = "origin.notification.name.update.song.menu"
        case UpdateArtistMenu = "origin.notification.name.update.artist.menu"
        case UpdateAlbumMenu = "origin.notification.name.update.album.menu"
        case UpdateHistoryMenu = "origin.notification.name.update.history.menu"
        case UpdateRssMenu = "origin.notification.name.update.rss.menu"
        case SkipToNextSong = "origin.notification.name.skip.to.next.item"
        case SkipToPreviousSong = "origin.notification.name.skip.to.previous.item"
        case CurrentItemDidChange = "origin.notification.name.current.item.did.change"
        case PlayerRateDidChange = "origin.notification.name.player.rate.did.change"
        case PlayerSetup = "origin.notification.name.player.setup"
        case UpdateCell = "origin.notification.name.update.cell"
    }

    init(key: key) {
        self = NSNotification.Name(rawValue: key.rawValue)
    }
}

extension SpringButton {
    func pop() {
        DispatchQueue.main.async {
            self.animation = "pop"
            self.duration = 0.3
            self.animate()
        }
    }
}

extension UIButton {

    func know() {
        self.isKnown = true
        self.imageView?.image = UIImage(image: .Known)
    }

    func unknown() {
        self.isKnown = false
        self.imageView?.image = UIImage(image: .Unknown)
    }

    var isKnown: Bool {
        get {
            return self.isSelected
        }
        set {
            self.isSelected = newValue
            print(self.isSelected)
            DispatchQueue.main.async {
                if self.isSelected {
                    self.imageView?.image = UIImage(image: .Known)
                } else {
                    self.imageView?.image = UIImage(image: .Unknown)
                }
            }
        }
    }
}

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

extension UITableViewCell {

    @IBInspectable var selectedBackgroundColor: UIColor? {
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

extension Results {
    var allObjects: [Element] {
        return self.map {$0}
    }
}

extension AudioItem {

    func saveRating(_ rating: Double) {
        let realm = try! Realm()
        let ratedSong = RatedSong()
        if let song = realm.object(ofType: Song.self, forPrimaryKey: self.id) {
            try! realm.write {
                song.rating = Int(rating)
                ratedSong.rating = Int(rating)
                realm.add(song, update: true)
                realm.add(ratedSong, update: true)
            }
        }
    }

    func saveKnown(_ isKnown: Bool) {
        let realm = try! Realm()
        let ratedSong = RatedSong()
        if let song = realm.object(ofType: Song.self, forPrimaryKey: self.id) {
            try! realm.write {
                song.isKnown = isKnown
                ratedSong.isKnown = isKnown
                realm.add(song, update: true)
                realm.add(ratedSong, update: true)
            }
        }
    }
}
