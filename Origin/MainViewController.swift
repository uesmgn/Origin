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
import Firebase
import RevealingSplashView

class MainViewController: UIViewController, UIGestureRecognizerDelegate, UITabBarDelegate {
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
    @IBOutlet weak var activityView: UIActivityIndicatorView!

    //--------------- Dispatch_queue ------------------
    /// DispatchQueue for UI
    var m_queue = DispatchQueue.main
    /// BackgroundQueue
    var b_queue = DispatchQueue.global()
    var revealingSplashView:RevealingSplashView = RevealingSplashView(iconImage: UIImage(named: "music-icon4")!,iconInitialSize: CGSize(width: 100, height: 100), backgroundColor: UIColor.black)
    //-------------- Property --------------------
    weak var containerView: UIView!
    fileprivate let vcArray = [UIViewController]()
    let player = AudioPlayer.shared
    let history = HistoryViewController.shared
    
    let nc = NotificationCenter.default // Notification Center
    var realm = try! Realm() //Realm
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setNotification()
        
        self.view.addSubview(revealingSplashView)
        
        // Splash View
        // セットアップされていたら遷移
        let setuped = UserDefaults.standard.string(forKey: "setuped")
        if setuped != nil  {
            revealingSplashView.startAnimation()
        }
    }
    
    func setNotification() {
        nc.addObserver(self, selector: #selector(self.set(_:)), name: NSNotification.Name(rawValue: "setup"), object: nil)
        nc.addObserver(self, selector: #selector(player.setup), name: NSNotification.Name(rawValue: "setup_player"), object: nil)
    }
    
    func set(_ notify: NSNotification) {
        // セットアップされていなかったとき
        Progress.stopProgress()
        DispatchQueue.main.async {
            self.revealingSplashView.startAnimation()
        }
        UserDefaults.standard.set(true,forKey:"setuped")
    }
}

extension MainViewController {
    // UI初期設定
    func setup() {
        tabBar.delegate = self
        player.viewController = self
        ratingBar.didFinishTouchingCosmos = didFinishTouchingCosmos
        
        activityView.isHidden = true
        radioButton.imageView?.image = UIImage(image: .Known)
        toggleButton.imageView?.image = UIImage(image: .Play)
        modeButton.imageView?.image = UIImage(image: .Shuffle)
        miniPlayerView.isHidden = true
        const.constant = -miniPlayerView.frame.size.height
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
        tabBar.selectedItem = homeTab // 最初はホームタブが選択
        self.homeContainer.isHidden = false
        self.discoverContainer.isHidden = true
        self.findContainer.isHidden = true
        self.historyContainer.isHidden = true
        PageTitle.text = "Library"
        containerView = homeContainer
        self.view.sendSubview(toBack: homeContainer)
    }
}

// ------------ Action ----------------
extension MainViewController {
    
    @IBAction func tapRadioButton(_ sender: Any) {
        let (usersong, othersong) = player.nowPlayingItem()
        guard (usersong ?? othersong) != nil else {
            return
        }
        radioButton.isKnown = !radioButton.isKnown
        let isKnown = radioButton.isKnown
        Save.known(isKnown)
        nc.post(name: NSNotification.Name(rawValue: "AddHistory"), object: nil)
    }
    
    fileprivate func didFinishTouchingCosmos(_ rating: Double) {
        let (usersong, othersong) = self.player.nowPlayingItem()
        guard (usersong ?? othersong) != nil else {
            return
        }
        Save.rating(rating)
        DispatchQueue.global().async {
            let jsonpost = JsonPost()
            jsonpost.post()
        }
        nc.post(name: NSNotification.Name(rawValue: "AddHistory"), object: nil)
    }
    
    // Didplay how to use
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
        m_queue.async {
            self.modeButton.animation = "pop"
            self.modeButton.imageView?.image = image
            self.modeButton.duration = 0.3
            self.modeButton.animate()
        }
        // maybe shuffle playlist
        AudioPlayer.shared.updatePlaylist()
    }
    
    @IBAction func tapToggleButton(_ sender: Any) {
        m_queue.async {
            self.toggleButton.animation = "pop"
            if self.player.isPlaying() {
                self.player.pause()
                self.toggleButton.imageView?.image = UIImage(image: .Play)
                self.toggleButton.duration = 0.3
                self.toggleButton.animate()
            } else {
                self.player.play()
                self.toggleButton.imageView?.image = UIImage(image: .Pause)
                self.toggleButton.duration = 0.3
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

extension MainViewController {
    
    func updatePlayinfo() {
        let (usersong, othersong) = self.player.nowPlayingItem()
        if let song = usersong, othersong == nil {
            self.miniplayerHidden(false)
            self.currentTitle.text = song.title
            self.currentDetail.text = song.artist
            self.currentArtwork.image = UIImage(data: song.artwork!)
            self.radioButton.isKnown = song.isKnown
            self.ratingBar.rating = Double(song.rating)
        } else if let song = othersong, usersong == nil {
            self.miniplayerHidden(false)
            self.const.constant = 0
            self.currentTitle.text = song.title
            self.currentDetail.text = song.artist
            self.currentArtwork.image = UIImage(named: "artwork_default")
            self.radioButton.isKnown = song.isKnown
            self.ratingBar.rating = Double(song.rating)
        } else {
            self.miniplayerHidden(true)
        }
        // Task: update playlist table
        self.nc.post(name: NSNotification.Name(rawValue: "updateCell"), object: nil)
    }
    
    func miniplayerHidden(_ hidden:Bool) {
        m_queue.async {
            if hidden {
                self.miniPlayerView.isHidden = true
                self.const.constant = -self.miniPlayerView.frame.size.height
            } else {
                self.miniPlayerView.isHidden = false
                self.const.constant = 0
            }
        }
    }
    
    func updateToggle() {
        m_queue.async {
            if self.player.isPlaying() {
                self.toggleButton.imageView?.image = UIImage(image: .Pause)
            } else {
                self.toggleButton.imageView?.image = UIImage(image: .Play)
            }
        }
    }
    
    // tab bar selected
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        setUI()
    }
    
    /// 各種UI設定
    func setUI() {
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

