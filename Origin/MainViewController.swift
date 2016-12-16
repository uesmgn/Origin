//
//  MainViewController.swift
//  Origin
//
//  Created by Gen on 2016/11/24.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit
import Foundation
import CoreData
import MediaPlayer
import APIKit
import Spring
import Cosmos
import RealmSwift
import Alamofire
import SVProgressHUD

class MainViewController: UIViewController, UIGestureRecognizerDelegate, UITabBarDelegate {
    
    //--------------- Dispatch_queue ------------------
    /// DispatchQueue for UI
    var m_queue = DispatchQueue.main
    /// BackgroundQueue
    var b_queue = DispatchQueue.global()
    
    //--------------- Outlet --------------------
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var miniPlayerView: MiniPlayerView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var homeTab: UITabBarItem!
    @IBOutlet weak var discoverTab: UITabBarItem!
    @IBOutlet weak var findTab: UITabBarItem!
    @IBOutlet weak var historyTab: UITabBarItem!
    @IBOutlet weak var homeContainer: UIView!
    @IBOutlet weak var discoverContainer: UIView!
    @IBOutlet weak var findContainer: UIView!
    @IBOutlet weak var PageTitle: UILabel!
    @IBOutlet weak var historyContainer: UIView!
    @IBOutlet weak var currentArtwork: UIImageView!
    @IBOutlet weak var currentTitle: UILabel!
    @IBOutlet weak var currentDetail: UILabel!
    @IBOutlet weak var toggleButton: SpringButton!
    @IBOutlet weak var nextButton: SpringButton!
    @IBOutlet weak var const: NSLayoutConstraint!
    @IBOutlet weak var modeButton: SpringButton!
    @IBOutlet weak var radioButton: SpringButton!
    //-------------- Property --------------------
    weak var containerView: UIView!
    fileprivate let vcArray = [UIViewController]()
    let player = AudioPlayer.shared
    let history = HistoryViewController.shared
    
    fileprivate let json = JsonAdmin()
    let nc = NotificationCenter.default // Notification Center
    var realm = try! Realm()
    
    func reset() {
        radioButton.isKnown = false
    }
    
    
    @IBAction func tapRadioButton(_ sender: Any) {
        radioButton.animation = "pop"
        let isKnown = radioButton.isKnown
        self.saveIsKnown(isKnown)
        if radioButton.isKnown {
            DispatchQueue.main.async {
                self.radioButton.unknown()
                self.radioButton.duration = 0.3
                self.radioButton.animate()
                Progress.showMessage("あなたはこの曲を知りませんでした")
            }
        } else {
            DispatchQueue.main.async {
                self.radioButton.know()
                self.radioButton.duration = 0.3
                self.radioButton.animate()
                Progress.showMessage("あなたはこの曲を知っています")
            }
        }
    }
    
    func saveIsKnown(_ isKnown:Bool) {
        let (usersong, othersong) = player.nowPlayingItem()
        if let song = usersong {
            try! realm.write {
                song.isKnown = isKnown
            }
        } else if let song = othersong {
            try! realm.write {
                song.isKnown = isKnown
            }
        }
    }
    /*
            // ライブラリーの曲に評価
            if let item = (song as? UserSong) {
                id = item.id
                if let usersong = realm.object(ofType: UserSong.self, forPrimaryKey: id) {
                    
                }
            }
            // プレビューに評価
            else if let item = (song as? OtherSong) {
                id = item.itunesId
                if let song = realm.object(ofType: OtherSong.self, forPrimaryKey: id) {
                    try! realm.write() {
                        song.isKnown = isKnown
                    }
                }
            }
            // 更新
            if let ratingsong = realm.object(ofType: RatedSong.self, forPrimaryKey: id) {
                try! realm.write() {
                    ratingsong.isKnown = isKnown
                }
            }
            // 新規追加
            else {
                let request = SaveRatedSongRequest(item: song)
                let ratingsong = try! request.response()
                try! self.realm.write {
                    self.realm.add(ratingsong!)
                }
            }
        }
    }*/

    // display song data
    @IBAction func tappedInfo(_ sender: Any) {
    
    }
    
    @IBAction func tapModeButton(_ sender: Any) {
        var image: UIImage?
        switch (player.mode) {
        case .Shuffle:
            player.updateMode(to: .Repeat)
            image = UIImage(image: .Repeat)
        case .Repeat:
            player.updateMode(to: .Stream)
            image = UIImage(image: .Stream)
        case .Stream:
            player.updateMode(to: .Shuffle)
            image = UIImage(image: .Shuffle)
        }
        modeButton.animation = "pop"
        DispatchQueue.main.async {
            self.modeButton.imageView?.image = image
            self.modeButton.duration = 0.3
            self.modeButton.animate()
        }
        AudioPlayer.shared.updatePlaylist()
    }
}

extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(MainViewController.animation), userInfo: nil, repeats: false)
        
        var timer2 = Timer.scheduledTimer(timeInterval: 3.5, target: self, selector: #selector(MainViewController.viewLoad), userInfo: nil, repeats: false)
        
        // delegate
        tabBar.delegate = self
        player.viewController = self
        
        ratingBar.didFinishTouchingCosmos = didFinishTouchingCosmos
        
        updatePlayinfo()
    }
    
    func viewLoad() {
        
        
    }
    func animation() {
        
        
    }
}


// --------------- Private Method -------------------
extension MainViewController {
    func updatePlayinfo() {
        guard (player.player) != nil else {
            self.miniPlayerView.isHidden = true
            self.setUI()
            return
        }
        DispatchQueue.main.async {
            let (usersong, othersong) = self.player.nowPlayingItem()
            if let song = usersong {
                self.miniPlayerView.isHidden = false
                self.const.constant = 0
                self.currentTitle.text = song.title
                self.currentDetail.text = song.artist
                self.currentArtwork.image = UIImage(data: song.artwork!)
                self.radioButton.isKnown = song.isKnown
                self.ratingBar.rating = Double(song.rating)
            } else if let song = othersong {
                self.miniPlayerView.isHidden = false
                self.const.constant = 0
                self.currentTitle.text = song.title
                self.currentDetail.text = song.artist
                self.currentArtwork.image = UIImage(named: "artwork_default")
                self.radioButton.isKnown = song.isKnown
                self.ratingBar.rating = Double(song.rating)
            } else {
                self.miniPlayerView.isHidden = true
                self.setUI()
            }
            self.nc.post(name: NSNotification.Name(rawValue: "updateCell"), object: nil)
        }
    }
    
    /// トグルボタンを押した時以外で再生状況が変化した時に呼び出し
    func updateToggle() {
        if player.isPlaying() {
            self.toggleButton.imageView?.image = UIImage(image: .Pause)
        } else {
            self.toggleButton.imageView?.image = UIImage(image: .Play)
        }
    }
    
    /// タブが選択された時に呼び出し
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        setUI()
    }

    fileprivate func didFinishTouchingCosmos(_ rating: Double) {
        let (usersong, othersong) = self.player.nowPlayingItem()
        var id:Int?
        var item:Any?
        // ライブラリーの曲に評価
        if let song = usersong {
            id = song.id
            item = song
            try! realm.write() {
                song.rating = Int(rating)
            }
        }
        // プレビューに評価
        else if let song = othersong {
            id = song.id
            item = song
            try! realm.write() {
                song.rating = Int(rating)
            }
        }
        guard id != nil else {
            return
        }
        let record = Record()
        var comment:String?
        // 更新
        if let ratingsong = realm.object(ofType: RatedSong.self, forPrimaryKey: id) {
            try! realm.write() {
                ratingsong.rating = Int(rating)
                let newValue = ratingsong.rating
                comment = "\(ratingsong.title)の評価値を\(newValue)に更新しました"
                Progress.showAlertWithRating(rating)
            }
        }
        // 新規追加
        else {
            let request = SaveRatedSongRequest(item: item!)
            let ratingsong = try! request.response()
            try! self.realm.write {
                comment = "\((ratingsong?.title)!)に評価値\(Int(rating))をつけました"
                Progress.showAlertWithRating(rating)
                self.realm.add(ratingsong!)
            }
            let objects = realm.objects(RatedSong.self)
            if objects.count % 10 == 0 {
                DispatchQueue.global().async {
                    Progress.showProgressWithMessage("評価した楽曲データからあなたへのプレイリストを作成しています")
                    // Task: 読み込み
                    let jsonpost = JsonPost(userId: 12345)
                    jsonpost.post()
                }
            }
        }
        try! realm.write {
            record.comment = comment!
            record.date = Date()
            realm.add(record)
        }
        nc.post(name: NSNotification.Name(rawValue: "AddHistory"), object: nil)
    }
    
    /// 各種UI設定
    func setUI() {
        //tabbar設定
        tabBar.barTintColor = UIColor(hex: "1e171a")
        homeTab.image = UIImage(named: "home-white-m")?.withRenderingMode(.alwaysOriginal)
        homeTab.selectedImage = UIImage(named: "home-green-m")?.withRenderingMode(.alwaysOriginal)
        discoverTab.image = UIImage(named: "discover-white-m")?.withRenderingMode(.alwaysOriginal)
        discoverTab.selectedImage = UIImage(named: "discover-green-m")?.withRenderingMode(.alwaysOriginal)
        findTab.image = UIImage(named: "light-white-m")?.withRenderingMode(.alwaysOriginal)
        findTab.selectedImage = UIImage(named: "light-green-m")?.withRenderingMode(.alwaysOriginal)
        historyTab.image = UIImage(named: "history-white-m")?.withRenderingMode(.alwaysOriginal)
        historyTab.selectedImage = UIImage(named: "history-green-m")?.withRenderingMode(.alwaysOriginal)
        let selectedColor   = UIColor(hex: "4caf50")
        let unselectedColor = UIColor.white
        let font = UIFont(name:"HelveticaNeue-Light",size:7)
        let attrsNormal = [
            NSForegroundColorAttributeName: unselectedColor,
            NSFontAttributeName: font
        ]
        let attrsSelected = [
            NSForegroundColorAttributeName: selectedColor,
            NSFontAttributeName: font
        ]
        UITabBarItem.appearance().setTitleTextAttributes(attrsNormal, for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes(attrsSelected, for: .selected)
        
        //tabbar動作設定
        guard let tag = tabBar.selectedItem?.tag else {
            tabBar.selectedItem = homeTab
            setUI()
            return
        }
        self.homeContainer.isHidden = !(tag == 1)
        self.discoverContainer.isHidden = !(tag == 2)
        self.findContainer.isHidden = !(tag == 3)
        self.historyContainer.isHidden = !(tag == 4)
        
        switch tag {
        case 1:
            PageTitle.text = "Library"
            containerView = homeContainer
            self.view.sendSubview(toBack: homeContainer)
        case 2:
            PageTitle.text = "Discover"
            containerView = discoverContainer
            self.view.sendSubview(toBack: discoverContainer)
        case 3:
            PageTitle.text = "Find"
            containerView = findContainer
            self.view.sendSubview(toBack: findContainer)
        case 4:
            PageTitle.text = "History"
            containerView = historyContainer
            self.view.sendSubview(toBack: historyContainer)
            nc.post(name: NSNotification.Name(rawValue: "AddHistory"), object: nil)
        default:
            return
        }
        let (usersong, othersong) = player.nowPlayingItem()
        if usersong != nil || othersong != nil {
            miniPlayerView.isHidden = false
            const.constant = 0
        } else {
            miniPlayerView.isHidden = true
            const.constant = -miniPlayerView.frame.size.height
        }
    }
    
}

// ------------ Action ----------------
extension MainViewController {
    
    @IBAction func tapToggleButton(_ sender: Any) {
        toggleButton.animation = "pop"
        if player.isPlaying() {
            DispatchQueue.main.async {
                self.player.pause()
                self.toggleButton.imageView?.image = UIImage(named: "play-1")
                self.toggleButton.duration = 0.4
                self.toggleButton.animate()
            }
        } else {
            DispatchQueue.main.async {
                self.player.play()
                self.toggleButton.imageView?.image = UIImage(named: "pause-1")
                self.toggleButton.duration = 0.4
                self.toggleButton.animate()
            }
        }
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
        m_queue.async {
            self.nextButton.animation = "pop"
            self.nextButton.duration = 0.3
            self.nextButton.animate()
        }
        player.skipToNextItem(1)
    }
}

