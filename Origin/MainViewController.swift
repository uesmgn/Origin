//
//  MainViewController.swift
//  Origin
//
//  Created by Gen on 2016/11/24.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import RealmSwift
import Alamofire
import SVProgressHUD
import Firebase
import RevealingSplashView

class MainViewController: UIViewController, UIGestureRecognizerDelegate, UITabBarDelegate {

    // MARK: Outlet
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var tab1: UITabBarItem!
    @IBOutlet weak var tab2: UITabBarItem!
    @IBOutlet weak var tab3: UITabBarItem!
    @IBOutlet weak var tab4: UITabBarItem!
    @IBOutlet weak var PageTitle: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var miniPlayerView: MiniPlayerView!

    var revealingSplashView: RevealingSplashView = RevealingSplashView(iconImage: UIImage(image: .Icon), iconInitialSize: CGSize(width: 100, height: 100), backgroundColor: UIColor.black)

    // MARK: Properties
    let vcArray = [UIViewController]()
    let player = AudioPlayer.shared
    let nc = NotificationCenter.default // Notification Center
    var realm = try! Realm() //Realm
    var vc1: HomeViewController?
    var vc2: DiscoverViewController?
    var vc3: FindViewController?
    var vc4: HistoryViewController?

    let history = HistoryViewController.shared
    var notificationToken: NotificationToken? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(revealingSplashView)

        tabBar.delegate = self
        player.delegate = self

        notificationInit()
        miniPlayerInit()
        tabbarInit()
        player.setup()

        let setuped = UserDefaults.standard.bool(forKey: "setuped")
        if setuped == true {
            revealingSplashView.startAnimation()
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

    }

    func set(_ notify: NSNotification) {
        Progress.stopProgress()
        DispatchQueue.main.async {
            self.revealingSplashView.startAnimation()
        }
        UserDefaults.standard.set(true, forKey:"setuped")
    }

    deinit { notificationToken?.stop() }
}

extension MainViewController {

    func notificationInit() {
        nc.addObserver(self, selector: #selector(self.set(_:)), name: NSNotification.Name(key: .Open), object: nil)
        nc.addObserver(self, selector: #selector(player.setup), name: NSNotification.Name(key: .PlayerSetup), object: nil)

        let results = realm.objects(RatedSong.self)
        notificationToken = results.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
            switch changes {
            case .initial: break
            case .update(_, deletions: _, insertions: _, modifications: _):
                if let id = self?.player.nowPlayingItemID() {
                    FirebasePost.post(id)
                }
            case .error(let error): print("\(error)") }
        }
    }

    func miniPlayerInit() {
        miniPlayerView.didChangeState = tapedToggle
        miniPlayerView.didChangeKnown = tapedKnown
        miniPlayerView.didChangeMode = tapedMode
        miniPlayerView.didFinishRating = didFinishRating
        miniPlayerView.isHidden = true
    }

    func tabbarInit() {
        tabBar.barTintColor = UIColor(hex: "1e171a")
        tab1.image = UIImage(named: "home-white-m")?.withRenderingMode(.alwaysOriginal)
        tab1.selectedImage = UIImage(named: "home-green-m")?.withRenderingMode(.alwaysOriginal)
        tab2.image = UIImage(named: "discover-white-m")?.withRenderingMode(.alwaysOriginal)
        tab2.selectedImage = UIImage(named: "discover-green-m")?.withRenderingMode(.alwaysOriginal)
        tab3.image = UIImage(named: "light-white-m")?.withRenderingMode(.alwaysOriginal)
        tab3.selectedImage = UIImage(named: "light-green-m")?.withRenderingMode(.alwaysOriginal)
        tab4.image = UIImage(named: "history-white-m")?.withRenderingMode(.alwaysOriginal)
        tab4.selectedImage = UIImage(named: "history-green-m")?.withRenderingMode(.alwaysOriginal)
        let selectedColor   = UIColor(hex: "4caf50")
        let unselectedColor = UIColor.white
        let font = UIFont(name:"Kohinoor Bangla", size:7)
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

        vc1 = createVC(name: "HomeViewController") as? HomeViewController
        vc2 = createVC(name: "DiscoverViewController") as? DiscoverViewController
        vc3 = createVC(name: "FindViewController") as? FindViewController
        vc4 = createVC(name: "HistoryViewController") as? HistoryViewController
        tabBar.selectedItem = tab1
        self.displayContentController(content: vc1!, container: containerView)
    }

    private func createVC(name: String) -> UIViewController {
        let controller = self.storyboard?.instantiateViewController(withIdentifier: name)
        return controller!
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        switch item {
        case tab1:
            displayContentController(content: vc1!, container: containerView)
        case tab2:
            displayContentController(content: vc2!, container: containerView)
        case tab3:
            displayContentController(content: vc3!, container: containerView)
        case tab4:
            displayContentController(content: vc4!, container: containerView)
        default: break
        }

    }

    func displayContentController(content: UIViewController, container: UIView) {
        addChildViewController(content)
        content.view.frame = container.bounds
        container.addSubview(content.view)
        content.didMove(toParentViewController: self)
    }
}

extension MainViewController {

    // MARK: Action

    @IBAction func tappedInfo(_ sender: Any) {

    }

    func didFinishRating(_ rating: Double) {
        let (usersong, othersong) = self.player.nowPlayingItem()
        guard (usersong ?? othersong) != nil else { return }
        Save.rating(rating)
        nc.post(name: NSNotification.Name(key: .UpdateHistoryMenu), object: nil)
    }

    func tapedKnown(_ isKnown: Bool) {
        let (usersong, othersong) = player.nowPlayingItem()
        guard (usersong ?? othersong) != nil else { return }
        Save.known(isKnown)
        nc.post(name: NSNotification.Name(key: .UpdateHistoryMenu), object: nil)
    }

    func tapedMode(_ mode: MiniPlayerView.Mode) {
        let (usersong, othersong) = self.player.nowPlayingItem()
        guard (usersong ?? othersong) != nil else { return }
        switch (mode) {
        case .Shuffle:
            player.updateMode(to: .Shuffle)
        case .Repeat:
            player.updateMode(to: .Repeat)
        case .Stream:
            player.updateMode(to: .Stream)
        }
        AudioPlayer.shared.updatePlaylist()
    }

    func tapedToggle(_ state: MiniPlayerView.State) {
        let (usersong, othersong) = self.player.nowPlayingItem()
        guard (usersong ?? othersong) != nil else { return }
        switch (state) {
        case .playing:
            player.play()
        case .paused:
            player.pause()
        }
    }
}

extension MainViewController {

    func updatePlayinfo() {
        let (usersong, othersong) = self.player.nowPlayingItem()
        print(self.player.nowPlayingItem())
        switch (player.status) {
        case .Loading(0):
            //loading(true)
            fallthrough
        case .Pause(0), .Play(0):
            if let song = usersong {
                self.miniPlayerView.isHidden = false
                self.miniPlayerView.title = "   "+song.title+" - "+song.artist+"   "
                self.miniPlayerView.isKnown = song.isKnown
                self.miniPlayerView.rating = Double(song.rating)
            }
        case .Loading(1):
            loading(true)
            fallthrough
        case .Pause(1), .Play(1):
            if let song = othersong {
                self.miniPlayerView.isHidden = false
                self.miniPlayerView.title = "   "+song.title+" - "+song.artist+"   "
                self.miniPlayerView.isKnown = song.isKnown
                self.miniPlayerView.rating = Double(song.rating)
            } else {
                print("else")
            }
        default:
            self.miniPlayerView.isHidden = true
        }
        // Task: update playlist table
        self.nc.post(name: NSNotification.Name(key: .UpdateCell), object: nil)
    }

    func loading(_ loading: Bool) {
    }

    func updateToggle() {
        DispatchQueue.main.async {
            if self.player.isPlaying() {
                self.miniPlayerView.state = .playing
            } else {
                self.miniPlayerView.state = .paused
            }
        }
    }

}
