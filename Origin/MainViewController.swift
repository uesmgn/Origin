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
import ARNTransitionAnimator
import RealmSwift
import Alamofire
import SVProgressHUD

class MainViewController: UIViewController, UIGestureRecognizerDelegate, UITabBarDelegate {
    
    //--------------- Dispatch_queue ------------------
    /// main queue: for UI
    open var m_queue = DispatchQueue.main
    
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
    @IBOutlet weak var plusButton: SpringButton!
    @IBOutlet weak var modeButton: SpringButton!
    
    //-------------- Property --------------------
    weak var containerView: UIView!
    fileprivate var animator : ARNTransitionAnimator?
    fileprivate var modalVC : CollectionViewController!
    fileprivate let vcArray = [UIViewController]()
    let player = AudioPlayer.shared
    let history = HistoryViewController.shared
    
    fileprivate let json = JsonAdmin()
    let nc = NotificationCenter.default // Notification Center
    var realm = try! Realm()
    
    // clear rating
    @IBAction func tappedClear(_ sender: Any) {
        let othersongs = realm.objects(OtherSong.self)
        try! self.realm.write {
            for song in othersongs {
                song.rating = 0
            }
        }
        let usersongs = realm.objects(UserSong.self)
        try! self.realm.write {
            for song in usersongs {
                song.rating = 0
            }
        }
    }
    
    // display song data
    @IBAction func tappedInfo(_ sender: Any) {
        let othersongs = realm.objects(OtherSong.self)
        for song in othersongs {
            print("\(song.itunesId),\(song.rating),\(song.title),\(song.artistName),\(song.albumTitle)")
        }
        print("\n")
        let usersongs = realm.objects(UserSong.self)
        for song in usersongs {
            print("\(song.id),\(song.rating),\(song.title),\(song.artist),\(song.album)")
        }
    }
    
    @IBAction func tapModeButton(_ sender: Any) {
        let mode = AudioPlayer.shared.mode
        print(mode)
        switch (mode) {
        case .Default:
            AudioPlayer.shared.mode = .Shuffle
            Progress.showMessage("Shuffle Mode")
        case .Shuffle:
            AudioPlayer.shared.mode = .Repeat
            Progress.showMessage("Repeat Mode")
        default:
            AudioPlayer.shared.mode = .Default
            Progress.showMessage("Streaming Mode")
            break
        }
        AudioPlayer.shared.updatePlaylist()
        self.updateModeButton()
    }
    
    func updateModeButton() {
        modeButton.animation = "pop"
        let mode = AudioPlayer.shared.mode
        switch (mode) {
        case .Default:
            DispatchQueue.main.async {
                self.modeButton.imageView?.image = UIImage(named: "stream")
                self.toggleButton.duration = 0.4
                self.toggleButton.animate()
            }
        case .Shuffle:
            DispatchQueue.main.async {
                self.modeButton.imageView?.image = UIImage(named: "shuffle")
                self.toggleButton.duration = 0.4
                self.toggleButton.animate()
            }
        case .Repeat:
            DispatchQueue.main.async {
                self.modeButton.imageView?.image = UIImage(named: "repeat")
                self.toggleButton.duration = 0.4
                self.toggleButton.animate()
            }
        }
    }
}

extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Task: 他のアプリで再生中の音声を停止

        // delegate
        tabBar.delegate = self
        player.viewController = self
        
        ratingBar.didFinishTouchingCosmos = didFinishTouchingCosmos
        
        updatePlayinfo()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.modalVC = storyboard.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController
        self.modalVC.modalPresentationStyle = .overFullScreen
        self.setupAnimator()
        
    }
}


// --------------- Private Method -------------------
extension MainViewController {
    func updatePlayinfo() {
        DispatchQueue.main.async {
            if let song = self.player.nowPlayingItem() {
                self.miniPlayerView.isHidden = false
                self.const.constant = 0
                if song as? UserSong != nil {
                    self.nextButton.isHidden = false
                    self.plusButton.isHidden = true
                    let item = song as! UserSong
                    self.currentTitle.text = item.title
                    self.currentDetail.text = item.artist
                    self.currentArtwork.image = UIImage(data: item.artwork!)
                    self.ratingBar.rating = Double(item.rating)
                } else if song as? OtherSong != nil {
                    self.nextButton.isHidden = true
                    self.plusButton.isHidden = false
                    let item = song as! OtherSong
                    self.currentTitle.text = item.title
                    self.currentDetail.text = item.artistName
                    self.currentArtwork.image = UIImage(named: "artwork_default")
                    self.ratingBar.rating = Double(item.rating)
                }
                self.toggleButton.imageView?.image = UIImage(named: "pause-1")
            } else {
                self.miniPlayerView.isHidden = true
                self.setUI()
                self.toggleButton.imageView?.image = UIImage(named: "play-1")
            }
            self.updateModeButton()
            self.nc.post(name: NSNotification.Name(rawValue: "updateCell"), object: nil)
        }
    }
    
    /// トグルボタンを押した時以外で再生状況が変化した時に呼び出し
    func updateToggle() {
        if player.isPlaying() {
            self.toggleButton.imageView?.image = UIImage(named: "pause-1")
        } else {
            self.toggleButton.imageView?.image = UIImage(named: "play-1")
        }
    }
    
    /// タブが選択された時に呼び出し
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        setUI()
    }
    

    fileprivate func didFinishTouchingCosmos(_ rating: Double) {
        if let song = player.nowPlayingItem() {
            var id:Int?
            // ライブラリーの曲に評価
            if let item = (song as? UserSong) {
                id = item.id
                if let usersong = realm.object(ofType: UserSong.self, forPrimaryKey: id) {
                    try! realm.write() {
                        usersong.rating = Int(rating)
                    }
                }
            }
            // プレビューに評価
            else if let item = (song as? OtherSong) {
                id = item.itunesId
                if let song = realm.object(ofType: OtherSong.self, forPrimaryKey: id) {
                    try! realm.write() {
                        song.rating = Int(rating)
                    }
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
                    print(comment!)
                }
            }
            // 新規追加
            else {
                let request = SaveRatedSongRequest(item: song)
                let ratingsong = try! request.response()
                try! self.realm.write {
                    comment = "\((ratingsong?.title)!)に評価値\(Int(rating))をつけました"
                    Progress.showAlertWithRating(rating)
                    self.realm.add(ratingsong!)
                    print(comment!)
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
        
        if player.nowPlayingItem() != nil {
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
    
    /// お気に入り追加
    @IBAction func plusButtonTapped(_ sender: Any) {
        if let song = player.nowPlayingItem() {
            let request = SaveFavoriteRequest(item: song)
            let song = try! request.response()
            let id = song?.itunesId
            guard realm.object(ofType: FavoriteSong.self, forPrimaryKey: id) == nil else {
                let message = "すでに追加されています"
                Progress.showAlert(message)
                return
            }
            if song != nil {
                guard song?.rating != 0 else {
                    let message = "評価してください"
                    Progress.showAlert(message)
                    return
                }
                try! self.realm.write {
                    self.realm.add(song!)
                    let message = "\((song?.title)!)をお気に入りに追加しました"
                    Progress.showMessage(message)
                }
                nc.post(name: NSNotification.Name(rawValue: "AddFavorite"), object: nil)
            }
        }
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
        m_queue.async {
            self.nextButton.animation = "pop"
            self.nextButton.duration = 0.4
            self.nextButton.animate()
        }
        player.skipToNextItem(1)
    }
}

// ---------------- Library ----------------
extension MainViewController {
    
    func setupAnimator() {
        let animation = TransitionAnimation(rootVC: self, modalVC: self.modalVC)
        animation.completion = { [weak self] isPresenting in
            if isPresenting {
                guard let _self = self else { return }
                let modalGestureHandler = TransitionGestureHandler(targetVC: _self, direction: .bottom)
                modalGestureHandler.registerGesture(_self.modalVC.view)
                modalGestureHandler.panCompletionThreshold = 15.0
                _self.animator?.registerInteractiveTransitioning(.dismiss, gestureHandler: modalGestureHandler)
            } else {
                self?.setupAnimator()
            }
        }
        
        let gestureHandler = TransitionGestureHandler(targetVC: self, direction: .top)
        gestureHandler.registerGesture(self.miniPlayerView)
        gestureHandler.panCompletionThreshold = 15.0
        
        self.animator = ARNTransitionAnimator(duration: 0.5, animation: animation)
        self.animator?.registerInteractiveTransitioning(.present, gestureHandler: gestureHandler)
        
        self.modalVC.transitioningDelegate = self.animator
    }
    
    fileprivate func generateImageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
}
