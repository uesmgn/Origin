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

class MainViewController: UIViewController, UIGestureRecognizerDelegate{
    //create dispatch queue
    /// メインキュー UI表示用タスク
    open var m_queue = DispatchQueue.main
    /// コンカレントキュー　優先度:最高　即座に処理
    open var h_queue = DispatchQueue(label: "c_queue", qos: .userInteractive, attributes: .concurrent)
    /// コンカレントキュー　優先度:高
    open var i_queue = DispatchQueue(label: "c_queue", qos: .userInitiated, attributes: .concurrent)
    /// コンカレントキュー　優先度:中
    open var d_queue = DispatchQueue(label: "c_queue", attributes: .concurrent)
    /// コンカレントキュー　優先度:低
    open var u_queue = DispatchQueue(label: "c_queue", qos: .utility, attributes: .concurrent)
    /// コンカレントキュー　優先度:最低　バックグラウンド動作用
    open var b_queue = DispatchQueue(label: "c_queue", qos: .background, attributes: .concurrent)
    /// シリアルキュー　優先度:中
    open var s_queue = DispatchQueue(label: "s_queue2")
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var miniPlayerView: MiniPlayerView!
    @IBOutlet weak var ratingBar: CosmosView!
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var currentArtwork: UIImageView!
    @IBOutlet weak var currentTitle: UILabel!
    @IBOutlet weak var currentDetail: UILabel!
    @IBOutlet weak var toggleButton: SpringButton!
    @IBOutlet weak var nextButton: SpringButton!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var containerBottom: NSLayoutConstraint!
    
    fileprivate var coredataAdmin = CoreDataAdmin()
    fileprivate var animator : ARNTransitionAnimator?
    fileprivate var modalVC : CollectionViewController!}

extension MainViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //musicplayer.stop()
        musicplayer.viewController = self
        s_queue.sync {
            musicplayer.allItemsToQueue()
            musicplayer.updatePlaylist()
        }
        coredataAdmin.viewController = self
        s_queue.sync {
            self.coredataAdmin.deleteAll(entityName: "History")
            self.coredataAdmin.defaultSetLibrary()
        }
        
        ratingBar.didFinishTouchingCosmos = didFinishTouchingCosmos
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.modalVC = storyboard.instantiateViewController(withIdentifier: "CollectionViewController") as? CollectionViewController
        self.modalVC.modalPresentationStyle = .overFullScreen
        
        self.setupAnimator()
        miniPlayerView.isHidden = true
        containerBottom.constant = -miniPlayerView.frame.size.height
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}


extension MainViewController {
    // update detail of now playing song
    func updatePlayinfo() {
        if let song = musicplayer.nowPlayingItem {
            miniPlayerView.isHidden = false
            containerBottom.constant = 0
            currentTitle.text = song.title ?? "unknown"
            currentDetail.text = song.artist ?? "unknown"
            currentArtwork.image = song.artwork?.image(at: currentArtwork.bounds.size) ?? UIImage(named: "artwork_default")
            //システム設定の評価値
            ratingBar.rating = Double(song.rating)
        } else {
            miniPlayerView.isHidden = true
            ratingView.isHidden = true
        }
    }
    
    func updateToggle() {
        if musicplayer.isPlaying() {
            self.toggleButton.imageView?.image = UIImage(named: "pause-1")
        } else {
            self.toggleButton.imageView?.image = UIImage(named: "play-1")
        }
    }
    
    fileprivate func didFinishTouchingCosmos(_ rating: Double) {
        if let song = musicplayer.nowPlayingItem {
            // システム設定の評価値変更
            musicplayer.setRating(Int(rating))
            // CoreDataに保存
            coredataAdmin.changeRatingOfLibrary(song: song, rating: rating)
            coredataAdmin.appendHistory(song: song, rating: rating)
        }
    }
}

// UI
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
