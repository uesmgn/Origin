//
//  MainViewController.swift
//  Origin
//
//  Created by Gen on 2016/11/24.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit
import CoreData
import MediaPlayer
import Spring
import Cosmos
import ARNTransitionAnimator
import RealmSwift


class MainViewController: UIViewController, UIGestureRecognizerDelegate, UITabBarDelegate {
    
    //--------------- Dispatch_queue ------------------
    /// main queue: for UI
    open var m_queue = DispatchQueue.main
    /// concurrent queue
    open var h_queue = DispatchQueue(label: "c_queue1", qos: .userInteractive, attributes: .concurrent)
    open var i_queue = DispatchQueue(label: "c_queue2", qos: .userInitiated, attributes: .concurrent)
    open var d_queue = DispatchQueue(label: "c_queue3", attributes: .concurrent)
    open var u_queue = DispatchQueue(label: "c_queue4", qos: .utility, attributes: .concurrent)
    open var b_queue = DispatchQueue(label: "c_queue5", qos: .background, attributes: .concurrent)
    /// serial queue
    open var s_queue = DispatchQueue(label: "s_queue")
    
    //--------------- Outlet --------------------
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var miniPlayerView: MiniPlayerView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var favTab: UITabBarItem!
    @IBOutlet weak var recTab: UITabBarItem!
    @IBOutlet weak var hisTab: UITabBarItem!
    @IBOutlet weak var libContainer: UIView!
    @IBOutlet weak var recContainer: UIView!
    @IBOutlet weak var hisContainer: UIView!
    @IBOutlet weak var PageTitle: UILabel!
    @IBOutlet weak var currentArtwork: UIImageView!
    @IBOutlet weak var currentTitle: UILabel!
    @IBOutlet weak var currentDetail: UILabel!
    @IBOutlet weak var toggleButton: SpringButton!
    @IBOutlet weak var nextButton: SpringButton!
    @IBOutlet weak var const: NSLayoutConstraint!
    @IBOutlet weak var plusButton: SpringButton!

    weak var containerView: UIView!
    //-------------- Property --------------------
    fileprivate var animator : ARNTransitionAnimator?
    fileprivate var modalVC : CollectionViewController!
    fileprivate let vcArray = [UIViewController]()
    let player = AudioPlayer.shared
    
    //-------------- Instanse ---------------
    fileprivate let json = JsonAdmin()
    
    let realm = try! Realm()
    
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
        if let song = player.nowPlayingItem() {
            miniPlayerView.isHidden = false
            const.constant = 0
            if song as? UserSong != nil {
                nextButton.isHidden = false
                plusButton.isHidden = true
                let item = song as! UserSong
                currentTitle.text = item.title
                currentDetail.text = item.artist
                currentArtwork.image = UIImage(data: item.artwork!)
                ratingBar.rating = Double(item.rating)
            } else if song as? Song != nil {
                nextButton.isHidden = true
                plusButton.isHidden = false
                let item = song as! Song
                currentTitle.text = item.title
                currentDetail.text = item.artist
                currentArtwork.image = UIImage(named: "artwork_default")
                ratingBar.rating = Double(item.rating)
            }
            //システム設定の評価値
            self.toggleButton.imageView?.image = UIImage(named: "pause-1")
        } else {
            miniPlayerView.isHidden = true
            setUI()
            self.toggleButton.imageView?.image = UIImage(named: "play-1")
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
                id = item.itunesId
                // ライブラリーの楽曲の評価値を更新
                let usersong = realm.object(ofType: UserSong.self, forPrimaryKey: id)
                try! realm.write() {
                    usersong?.rating = Int(rating)
                }
            }
            // プレビューに評価
            else if let item = (song as? Song) {
                id = item.itunesId
                if let song = realm.object(ofType: Song.self, forPrimaryKey: id) {
                    try! realm.write() {
                        song.rating = Int(rating)
                    }
                }
            }
            guard id != nil else {
                return
            }
            // 更新
            if let ratingsong = realm.object(ofType: RatedSong.self, forPrimaryKey: id) {
                try! realm.write() {
                    let oldVlaue = ratingsong.rating
                    ratingsong.rating = Int(rating)
                    let newValue = ratingsong.rating
                    print("\(ratingsong.title)の評価値を更新:\(oldVlaue)->\(newValue)")
                }
            }
            // 新規追加
            else {
                let request = SaveRatedSongRequest(item: song)
                let song = try! request.response()
                try! self.realm.write {
                    self.realm.add(song!)
                    print("\((song?.title)!)を評価しました:\((song?.rating)!)")
                }
            }
        }
    }
    
    /// 各種UI設定
    func setUI() {
        //tabbar設定
        tabBar.barTintColor = UIColor(hex: "1e171a")
        favTab.image = UIImage(named: "home-white-m")?.withRenderingMode(.alwaysOriginal)
        favTab.selectedImage = UIImage(named: "home-green-m")?.withRenderingMode(.alwaysOriginal)
        recTab.image = UIImage(named: "discover-white-m")?.withRenderingMode(.alwaysOriginal)
        recTab.selectedImage = UIImage(named: "discover-green-m")?.withRenderingMode(.alwaysOriginal)
        hisTab.image = UIImage(named: "light-white-m")?.withRenderingMode(.alwaysOriginal)
        hisTab.selectedImage = UIImage(named: "light-green-m")?.withRenderingMode(.alwaysOriginal)
        let selectedColor   = UIColor(hex: "4caf50")
        let unselectedColor = UIColor.white
        let font = UIFont(name:"HelveticaNeue-Light",size:6)
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
            tabBar.selectedItem = favTab
            setUI()
            return
        }
        self.libContainer.isHidden = !(tag == 1)
        self.recContainer.isHidden = !(tag == 2)
        self.hisContainer.isHidden = !(tag == 3)
        
        switch tag {
        case 1:
            PageTitle.text = "Library"
            containerView = libContainer
            self.view.sendSubview(toBack: libContainer)
        case 2:
            PageTitle.text = "Discover"
            containerView = recContainer
            self.view.sendSubview(toBack: recContainer)
        case 3:
            PageTitle.text = "Find"
            containerView = hisContainer
            self.view.sendSubview(toBack: hisContainer)
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
    /*
    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }*/
    
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
                print("すでに追加されています")
                return
            }
            if song != nil {
                guard song?.rating != 0 else {
                    print("評価してください")
                    return
                }
                try! self.realm.write {
                    self.realm.add(song!)
                    print("\((song?.title)!)をお気に入りに追加しました")
                }
            }
        }
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
        m_queue.async {
            self.nextButton.animation = "pop"
            self.nextButton.duration = 0.4
            self.nextButton.animate()
        }
        player.skipToNextItem()
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
