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

var musicplayer = MusicPlayerController()

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
    weak var containerView: UIView!
    
    //-------------- Property --------------------
    fileprivate var coredataAdmin = CoreDataAdmin()
    fileprivate var animator : ARNTransitionAnimator?
    fileprivate var modalVC : CollectionViewController!
    fileprivate let vcArray = [UIViewController]()

    //-------------- Instanse ---------------
    fileprivate let json = JsonAdmin()
}

extension MainViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Task: 他のアプリで再生中の音声を停止
        musicplayer.setBackgroundMode()
        
        // delegate
        tabBar.delegate = self
        musicplayer.viewController = self
        coredataAdmin.viewController = self
        ratingBar.didFinishTouchingCosmos = didFinishTouchingCosmos
        
        updatePlayinfo()
        
        s_queue.sync {
            musicplayer.allItemsToQueue()
            musicplayer.updatePlaylist()
        }
        s_queue.sync {
            self.coredataAdmin.deleteAll(entityName: "History")
            self.coredataAdmin.defaultSetLibrary()
        }
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.modalVC = storyboard.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController
        self.modalVC.modalPresentationStyle = .overFullScreen
        self.setupAnimator()
    }
}


// --------------- Private Method -------------------
extension MainViewController {
    
    /// 再生中の曲情報を表示
    func updatePlayinfo() {
        if let song = musicplayer.nowPlayingItem {
            miniPlayerView.isHidden = false
            const.constant = 0
            
            currentTitle.text = song.title ?? "unknown"
            currentDetail.text = song.artist ?? "unknown"
            currentArtwork.image = song.artwork?.image(at: currentArtwork.bounds.size) ?? UIImage(named: "artwork_default")
            //システム設定の評価値
            ratingBar.rating = Double(song.rating)
            self.toggleButton.imageView?.image = UIImage(named: "pause-1")
        } else {
            setUI()
            self.toggleButton.imageView?.image = UIImage(named: "play-1")
        }
    }
    
    /// トグルボタンを押した時以外で再生状況が変化した時に呼び出し
    func updateToggle() {
        if musicplayer.isPlaying() {
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
        if let song = musicplayer.nowPlayingItem {
            
            musicplayer.setRating(Int(rating))
            // Save to CoreData; LibraryData,HistoryData
            coredataAdmin.changeRatingOfLibrary(song: song, rating: rating)
            coredataAdmin.appendHistory(song: song, rating: rating)
        }
    }
    
    /// 各種UI設定
    func setUI() {
        guard let tag = tabBar.selectedItem?.tag else {
            tabBar.selectedItem = favTab
            setUI()
            return
        }
        self.libContainer.isHidden = !(tag == 1)
        self.hisContainer.isHidden = !(tag == 2)
        self.recContainer.isHidden = !(tag == 3)
        
        switch tag {
        case 1:
            PageTitle.text = "Songs"
            containerView = libContainer
            self.view.sendSubview(toBack: libContainer)
        case 2:
            PageTitle.text = "Recommendation"
            containerView = recContainer
            self.view.sendSubview(toBack: recContainer)
        case 3:
            PageTitle.text = "History"
            containerView = hisContainer
            self.view.sendSubview(toBack: hisContainer)
        default:
            return
        }
        
        if musicplayer.nowPlayingItem != nil {
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
    
    @IBAction func backToHome(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func tapToggleButton(_ sender: Any) {
        toggleButton.animation = "pop"
        if musicplayer.isPlaying() {
            DispatchQueue.main.async {
                musicplayer.pause()
                self.toggleButton.imageView?.image = UIImage(named: "play-1")
                self.toggleButton.duration = 0.4
                self.toggleButton.animate()
            }
        } else {
            DispatchQueue.main.async {
                musicplayer.play()
                self.toggleButton.imageView?.image = UIImage(named: "pause-1")
                self.toggleButton.duration = 0.4
                self.toggleButton.animate()
            }
        }
    }
    
    @IBAction func tapNextButton(_ sender: Any) {
        m_queue.async {
            self.nextButton.animation = "pop"
            self.nextButton.duration = 0.4
            self.nextButton.animate()
        }
        musicplayer.skipToNextItem()
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
