//
//  AppDelegate.swift
//  Origin
//
//  Created by Gen on 2016/11/24.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit
import CoreData
import RealmSwift
import MediaPlayer
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    let nc = NotificationCenter.default
    var realm: Realm = try! Realm()
    let player = AudioManager.shared

    override init() {
        super.init()
        // firebase initialization
        FIRApp.configure()
        // off line persistence
        FIRDatabase.database().persistenceEnabled = true
        // Task: Interrupption processing
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // Get unique ID
        let uuid = UserDefaults.standard.string(forKey: "uuid")
        if uuid == nil {
            UserDefaults.standard.set(NSUUID().uuidString, forKey:"uuid")
        }

        // Permit remote control
        initRemoteControl()

        let authorized = UserDefaults.standard.bool(forKey: "authorized")
        print(authorized)
        if authorized == false {
            // メディアライブラリーへのアクセスが許可されていなかったら
            set()
        } else {
            // メディアライブラリーへのアクセスが許可されていたら
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatelibrary"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updaterss"), object: nil)
            }
        }
        return true
    }

    func set() {
        ItunesRssHelper.createPlaylist()
        if #available(iOS 9.3, *) {
            let authorizationStatus = MPMediaLibrary.authorizationStatus()
            switch authorizationStatus {
            case .authorized:
                Progress.start()
                UserDefaults.standard.set(true, forKey: "authorized")
                MediaLibraryHelper.createPlaylist()
                break
            case .notDetermined:
                MPMediaLibrary.requestAuthorization({[weak self] (_) in
                    self?.set()
                })
            case .denied, .restricted:
                return
            }
        }
        // load table
        nc.post(name: NSNotification.Name(key: .UpdateSongMenu), object: nil)
        nc.post(name: NSNotification.Name(key: .UpdateAlbumMenu), object: nil)
        nc.post(name: NSNotification.Name(key: .UpdateArtistMenu), object: nil)
        // splash view open
        nc.post(name: NSNotification.Name(key: .Open), object: nil)
    }

    func initRemoteControl() {
        try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        try! AVAudioSession.sharedInstance().setActive(true)
        UIApplication.shared.becomeFirstResponder()
        UIApplication.shared.beginReceivingRemoteControlEvents()
    }
}
