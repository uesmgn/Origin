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
    @IBOutlet weak var playerView: PlayerView!

    // MARK: Properties
    let revealingSplashView: RevealingSplashView = RevealingSplashView(iconImage: UIImage(image: .Icon), iconInitialSize: CGSize(width: 100, height: 100), backgroundColor: UIColor.black)
    let vcArray = [UIViewController]()
    let shared = AudioManager.shared
    let history = HistoryViewController.shared
    let nc = NotificationCenter.default // Notification Center
    var realm = try! Realm() //Realm
    var vc1: HomeViewController?
    var vc2: DiscoverViewController?
    var vc3: FindViewController?
    var vc4: HistoryViewController?
    var notificationToken: NotificationToken? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(revealingSplashView)

        tabBar.delegate = self
        shared.delegate = self
        playerView.didChangeKnown = didChangeKnown
        playerView.didFinishRating = didFinishRating

        notificationInit()
        tabbarInit()
        shared.initiarize()

        let setuped = UserDefaults.standard.bool(forKey: "setuped")
        if setuped == true {
            revealingSplashView.startAnimation()
        }
    }

    override func remoteControlReceived(with event: UIEvent?) {
        if let event = event {
            shared.player.remoteControlReceived(with: event)
        }
    }

    func notificationInit() {
        nc.addObserver(self, selector: #selector(self.set(_:)), name: NSNotification.Name(key: .Open), object: nil)
        // RatedSongが更新されたらFirebaseを更新
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

    func set(_ notify: NSNotification) {
        Progress.stopProgress()
        DispatchQueue.main.async {
            self.revealingSplashView.startAnimation()
        }
        UserDefaults.standard.set(true, forKey:"setuped")
    }
}

extension MainViewController {

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

    private func displayContentController(content: UIViewController, container: UIView) {
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
        nc.post(name: NSNotification.Name(key: .UpdateHistoryMenu), object: nil)
    }

    func didChangeKnown(_ isKnown: Bool) {
        nc.post(name: NSNotification.Name(key: .UpdateHistoryMenu), object: nil)
    }
}

extension MainViewController {
}
