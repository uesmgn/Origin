//
//  player.swift
//  Origin
//
//  Created by Gen on 2016/12/03.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import MediaPlayer
import RealmSwift

class AudioPlayer: NSObject, AVAudioPlayerDelegate {
    // singleton
    static let shared = AudioPlayer()
    static let nc = MPNowPlayingInfoCenter.default()
    // delegate
    weak var viewController:MainViewController!
    
    let realm = try! Realm()
    var player: AVAudioPlayer!
    
    // status of player
    enum Status {
        case LibraryPlaying
        case PreviewPlaying
        case Pausing
    }
    
    var status:Status?
    var LibraryArtworks:[UIImage] = []
    
    /// Library array
    var  Library:[UserSong] {
        var songs: [UserSong] = []
        let realmResponse = realm.objects(UserSong.self)
        for result in realmResponse {
            songs.append(result)
        }
        return songs
    }
    
    /// default result srray
    var Songs:[Song] {
        var songs: [Song] = []
        let realmResponse = realm.objects(Song.self)
        for result in realmResponse {
            songs.append(result)
        }
        return songs
    }

    // 
    var libraryIndex:Int = 0
    var songsIndex:Int = 0
    
    var usersong:UserSong? {
        didSet {
            status = .LibraryPlaying
            self.initRemoteControl()
            let fileUrl = URL(string: self.usersong!.trackSource)
            player = try! AVAudioPlayer(contentsOf: fileUrl!)
            player.delegate = self
            player.prepareToPlay()
            viewController?.updatePlayinfo()
        }
    }
    
    var song:Song? {
        didSet {
            status = .PreviewPlaying
            self.initRemoteControl()
            let fileUrl = URL(string: self.song!.trackSource)
            let soundData = try! Data(contentsOf: fileUrl!)
            player = try! AVAudioPlayer(data: soundData)
            player.delegate = self
            player.prepareToPlay()
            viewController?.updatePlayinfo()
        }
    }
    
    private func playerBeginInterruption(_ player: AVAudioPlayer) {
        print("interruption")
        player.pause()
        status = .Pausing
    }
    
    private func playerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        print("end interruption")
        player.play()
        
    }
    
    func play() {
        if let player = player {
            player.play()
        }
    }
    
    func stop() {
        if let player = player {
            player.stop()
            status = .Pausing
            viewController?.updatePlayinfo()
        }
    }
    
    func pause() {
        if let player = player {
            player.pause()
        }
    }
    
    func pos(_ time: Double) {
        if let player = player {
            player.currentTime = time
        }
    }
    
    //
    func itemChanged() {
        
    }
    
    func skipToNextItem() {
        switch (status!) {
        case .LibraryPlaying:
            libraryIndex = Library.index(of: usersong!)! as Int
            guard libraryIndex + 1 < Library.count else {
                stop()
                return // Task:はじめに戻る　or 終了
            }
            libraryIndex += 1
            let item = Library[libraryIndex]
            usersong = item
            let fileUrl = URL(string: item.trackSource)
            player = try! AVAudioPlayer(contentsOf: fileUrl!)
            player.prepareToPlay()
            player.play()
            viewController?.updatePlayinfo()
            break
        case .PreviewPlaying:
            songsIndex = Songs.index(of: song!)! as Int
            guard songsIndex + 1 < Songs.count else {
                stop()
                return // Task:はじめに戻る　or 終了
            }
            songsIndex += 1
            let item = Songs[songsIndex]
            song = item
            let fileUrl = URL(string: item.trackSource)
            let soundData = try! Data(contentsOf: fileUrl!)
            player = try! AVAudioPlayer(data: soundData)
            player.prepareToPlay()
            player.play()
            viewController?.updatePlayinfo()
            break
        default:
            // Task: 停止のまま次の曲へ遷移
            break
        }
    }
    
    func skipToPreviousItem() {
    }
    
    func currentTime() -> Double {
        if let player = player {
            return player.currentTime
        }
        return 0.0
    }
    
    func currentTimeStr() -> String {
        if let player = player {
            let origin = player.currentTime
            let min = Int(origin/60)
            let sec = NSString(format: "%02d", Int(origin.truncatingRemainder(dividingBy: 60)))
            return "\(min):\(sec)"
        }
        return "0:00"
    }
    
    func isPlaying() -> Bool {
        if let player = player {
            return player.isPlaying
        }
        return false
    }
}

extension AudioPlayer {
    // 再生中の曲
    func nowPlayingItem() -> Any? {
        if (player) != nil {
        switch (status!) {
            case .LibraryPlaying:
                return usersong
            case .PreviewPlaying:
                return song
            default:
                return nil
            }
        }
        return nil
    }
    
    func playerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        itemChanged()
        viewController?.updatePlayinfo()
        viewController?.updateToggle()
        let notification = Notification(name: Notification.Name(rawValue: "finishPlayer"), object: nil)
        NotificationCenter.default.post(notification)
    }
    
    func initRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        //self.becomeFirstResponder()
        do  {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            //print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                //print("AVAudioSession is Active")
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
}
