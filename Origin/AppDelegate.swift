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
import APIKit
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController?
    let nc = NotificationCenter.default
    var realm:Realm
    var library = [MPMediaItem]()
    
    override init() {
        realm = try! Realm()
    }
    
    // 初回起動時実行
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // ライブラリーの曲をRealmに保存            
        let Songs = realm.objects(UserSong.self)
        if Songs.count == 0 {
            authorize()
        }
        
        // デフォルトのプレビューデータをRealmに保存
        let songs = realm.objects(OtherSong.self)
        if songs.count == 0 {
            setAllRss()
            setGenreRss()
        }
        return true
    }
    
    func authorize() {
        if #available(iOS 9.3, *) {
            let authorizationStatus = MPMediaLibrary.authorizationStatus()
            switch authorizationStatus {
            case .authorized:
                Progress.showProgressWithMessage("メディアライブラリーの曲を読み込んでいます")
                let query = MPMediaQuery.songs()
                print("query: \(query.items?.count)")
                if query.items?.count == 0  {
                    self.library = []
                } else {
                    print(query.items!.count)
                    for item in query.items! {
                        library.append(item)
                    }
                }
            case .notDetermined:
                MPMediaLibrary.requestAuthorization({[weak self] (newAuthorizationStatus: MPMediaLibraryAuthorizationStatus) in
                    self?.authorize()
                })
            case .denied, .restricted:
                return
            }
        }
        if library.count != 0 {
            let albumReq = AlbumsRequest()
            let albums = try! albumReq.response()
            realm = try! Realm()// 入れないとエラー
            try! self.realm.write {
                self.realm.add(albums)
            }
            setArtist()
        } else {
            Progress.stopProgress()
            Progress.showAlert("ライブラリーに曲がありません")
        }
        Progress.stopProgress()
        nc.post(name: NSNotification.Name(rawValue: "setLibrary"), object: nil)
        
    }
    
    func setArtist() {
        var artistNameArray:[String] = []
        let albums = self.realm.objects(Album.self)
        for album in albums {
            if !artistNameArray.contains(album.artistName) {
                artistNameArray.append(album.artistName)
            }
        }
        print(artistNameArray)
        for artistName in artistNameArray {
            let artist = Artist()
            let objects = self.realm.objects(Album.self).filter("artistName = '\(artistName)'") // Change: 12/09 by Gen
            print("\(artistName):\(objects.count)")
            artist.albums.append(objectsIn: objects)
            artist.artistName = artistName
            try! self.realm.write {
                self.realm.add(artist)
            }
        }
        nc.post(name: NSNotification.Name(rawValue: "setArtist"), object: nil)
    }
    
    func setAllRss() {
        let request = ALlRssRequest()
        request.getRss()
        nc.post(name: NSNotification.Name(rawValue: "setRss"), object: nil)
    }
    
    func setGenreRss() {
        let genreDict = ["Pop":"14","R&B/Soul":"15","Dance":"17","Hip-Hop/Rap":"18","Alternative":"20","Rock":"21","J-POP":"27"]
        for genre in genreDict.values {
            let request = GenreRssRequest(genre: genre)
            request.getRss()
        }
        nc.post(name: NSNotification.Name(rawValue: "setRss"), object: nil)
    }
    
    func setItems(_ term: String) {
        let request = GetSearchRequest(term: term)
        Session.send(request) { result in
            switch result {
            case .success(let songs):
                for song in songs {
                    try! self.realm.write {
                        self.realm.add(song)
                    }
                }
            case .failure:
                print("error")
            }
        }
    }


    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "Origin")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as NSURL
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Origin", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    lazy var managedObjectContext: NSManagedObjectContext = {
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()


}

