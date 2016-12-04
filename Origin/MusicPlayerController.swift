//
//  MusicPlayerController.swift
//  Origin
//
//  Created by Gen on 2016/11/24.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVFoundation
import CoreData

class MusicPlayerController: NSObject, AVAudioPlayerDelegate{
    
    //singleton
    static let shared = MusicPlayerController()
    
    //------------ Property ------------------
    weak var viewController:MainViewController?
    weak var songTable:SongViewController?
    weak var artistTable:ArtistViewController?
    weak var albumTable:AlbumViewController?
    weak var collectionView:CollectionViewController?
    
    let player = MPMusicPlayerController.applicationMusicPlayer()
    
    var nowPlayingItem: MPMediaItem? {
        get {
            return player.nowPlayingItem
        }
        set {
            player.nowPlayingItem = newValue
        }
    }
    
    var playlist = [MPMediaItem]() {
        didSet {
            playlistToQueue()
        }
    }
    
    //------------ Delegate ------------------
    override init() {
        super.init()
        registAllObserver()
    }
    
    deinit {
        removeAllObserver()
    }
    
    //------------ Method ------------------
    
    func registAllObserver() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.launch(notify:)), name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
        nc.addObserver(self, selector: #selector(self.didEnterBackground(notify:)), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        nc.addObserver(self, selector: #selector(self.willEnterForeground(notify:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        nc.addObserver(self, selector: #selector(self.playItemChanged(notify:)), name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        nc.addObserver(self, selector: #selector(self.playbackStateDidChange(notify:)), name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: nil)
        player.beginGeneratingPlaybackNotifications()
    }
    
    func removeAllObserver() {
        player.endGeneratingPlaybackNotifications()
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: NSNotification.Name.UIApplicationDidFinishLaunching, object: nil)
        nc.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        nc.removeObserver(self, name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        nc.removeObserver(self, name: NSNotification.Name.MPMusicPlayerControllerNowPlayingItemDidChange, object: player)
        nc.removeObserver(self, name: NSNotification.Name.MPMusicPlayerControllerPlaybackStateDidChange, object: player)
    }
    
    func launch(notify: NSNotification) {
    }
    func didEnterBackground(notify: NSNotification) {
    }
    
    func willEnterForeground(notify: NSNotification) {
    }
    
    func playItemChanged(notify: NSNotification) {
        viewController?.updatePlayinfo()
        songTable?.tableView.reloadData()
        artistTable?.tableView.reloadData()
        albumTable?.tableView.reloadData()
        songTable?.sclollToCurrentItem(animated: true)
        artistTable?.sclollToCurrentItem(animated: true)
        albumTable?.sclollToCurrentItem(animated: true)
        collectionView?.sclollToCurrentItem(animated: true)
    }
    
    func playbackStateDidChange(notify: NSNotification) {
    }
    
    
    
    
    func updatePlaylist() {
        let query = MPMediaQuery.songs()
        let num = NSNumber(value: false as Bool)
        let pre = MPMediaPropertyPredicate(value: num, forProperty: MPMediaItemPropertyIsCloudItem)
        query.addFilterPredicate(pre)
       
        guard let items = query.items else {
            return
        }
        playlist = items
        songTable?.songCountLabel.text = "\(playlist.count) Songs"
    }
    
    func  playlistToQueue() {
        if playlist.isEmpty == false {
            let collection = MPMediaItemCollection(items: playlist)
            player.setQueue(with: collection)
        }
    }
    
    func allItemsToQueue() {
        let query = MPMediaQuery.songs()
        player.setQueue(with: query)
    }
    
    
    
    
    
    //----------------- Controller -------------------------
    
    func isPlaying() -> Bool {
        let av = AVAudioSession.sharedInstance()
        return av.isOtherAudioPlaying
    }
    
    func play() {
        player.play()
    }
    
    func play(_ no: Int) {
        
        player.nowPlayingItem = playlist[no]
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.stop()
    }
    
    func skipToNextItem() {
        player.skipToNextItem()
    }
    
    func skipToPreviousItem() {
        player.skipToPreviousItem()
    }
    
    func currentTime() -> Double {
        return player.currentPlaybackTime
    }
    
    func setRating(_ rating : Int) {
        if let item = musicplayer.nowPlayingItem {
            item.setValue(NSNumber(value:rating), forKey: MPMediaItemPropertyRating)
        }
    }
    
    func setBackgroundMode() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch  {
            fatalError("カテゴリ設定失敗")
        }
        do {
        try session.setActive(true)
        } catch {
            fatalError("session有効化失敗")
        }
    }
}


