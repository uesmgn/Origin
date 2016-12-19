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


class AudioPlayer: NSObject {
    
    // singleton
    static let shared = AudioPlayer()
    static let nc = MPNowPlayingInfoCenter.default()
    // delegate
    weak var viewController:MainViewController!
    
    let realm = try! Realm()
    var player: AVAudioPlayer!
    
    let queue = OperationQueue()
    let m_queue = DispatchQueue.main
    let g_queue = DispatchQueue.global()
    
    
    // STATUS
    enum Status {
        case Play(Int) // Library:0 iTunes:1
        case Pause(Int) // Library:0 iTunes:1
        case Stop
        case Loading(Int)
    }
    
    enum Mode {
        case Shuffle
        case Repeat
        case Stream
    }
    
    var status:Status {
        didSet {
            print("status change"+"\(oldValue)->\(status)")
            self.viewController?.updatePlayinfo()
        }
    }
    
    var mode:Mode
    
    func nowPlayingItem() -> (UserSong?, OtherSong?) {
        switch (status) {
        case .Play(0), .Pause(0), .Loading(0):
            return (usersong, nil)
        case .Play(1), .Pause(1), .Loading(1):
            return (nil, othersong)
        default:
            return (nil,nil)
        }
    }
    
    func isPlaying() -> Bool {
        if let player = player {
            switch (status) {
            case .Loading:
                return false
            default:
                break
            }
            return player.isPlaying
        }
        return false
    }
    
    // current index
    var L_Index = 0
    var O_Index = 0
    // url
    var L_Playlist:[String] = []
    var O_Playlist:[String] = []
    // url:id
    var L_PlaylistDict:[String:Int] = [:]
    var O_PlaylistDict:[String:Int] = [:]
    
    var setuped:Bool = false
    var retry = 0
    
    let nc = NotificationCenter.default // Notification Center

    override init() {
        self.mode = .Shuffle
        self.status = .Stop
    }
    
    var Library:[UserSong] = []
    var Other:[OtherSong] = []
    
    // 起動時に実行
    func setup() {
        var array = [String]()
        var idDict = [String:Int]()
        for song in realm.objects(UserSong.self) {
            array.append(song.trackSource)
            idDict[song.trackSource] = song.id
        }
        self.L_Playlist = array
        self.L_PlaylistDict = idDict
        
        var l_songs = [UserSong]()
        let l_Response = realm.objects(UserSong.self)
        for result in l_Response {
            l_songs.append(result)
        }
        Library =  l_songs
        
        array.removeAll()
        idDict.removeAll()
        for song in realm.objects(OtherSong.self) {
            array.append(song.trackSource)
            idDict[song.trackSource] = song.id
        }
        self.O_Playlist = array
        self.O_PlaylistDict = idDict
        
        var o_songs = [OtherSong]()
        let o_Response = realm.objects(OtherSong.self)
        for result in o_Response {
            o_songs.append(result)
        }
        Other =  o_songs
        if mode == .Shuffle {
            L_Playlist.shuffle()
            O_Playlist.shuffle()
        }
        setuped = true
    }
    
    // * Do this method in main thread
    func updatePlaylist() {
        switch (mode) {
        case .Shuffle:
            if L_Playlist.count != 0 {
                L_Playlist.shuffle()
            }
            if O_Playlist.count != 0 {
                O_Playlist.shuffle()
            }
        default: setup()
        }
    }
    
    func updateMode(to mode: Mode) {
        self.mode = mode
        Progress.showWithMode(mode)
        updatePlaylist()
    }
    
    var usersong:UserSong? {
        willSet {
            initRemoteControl()
            queue.cancelAllOperations()
        }
        didSet {
            guard let song = self.usersong else {
                return
            }
            status = .Loading(0)
            self.L_Index = self.L_Playlist.index(of: song.trackSource) ?? 0
            let url = URL(string: song.trackSource)
            queue.addOperation {
                do {
                    self.player = try AVAudioPlayer(contentsOf: url!)
                    self.prepareToPlay()
                } catch {
                    print("error")
                }
            }
        }
    }
    
    var othersong:OtherSong? {
        willSet {
            initRemoteControl()
            pause()
            queue.cancelAllOperations()
        }
        didSet {
            guard let song = self.othersong else {
                return
            }
            self.status = .Loading(1)
            self.O_Index = self.O_Playlist.index(of: song.trackSource) ?? 0
            let url = URL(string: song.trackSource)
            queue.addOperation {
                do {
                    let soundData = try Data(contentsOf: url!)
                    self.player = try AVAudioPlayer(data: soundData)
                    self.prepareToPlay()
                } catch {
                    print("error")
                }
            }
        }
    }
    
    func prepareToPlay() {
        guard let player = player else {
            return
        }
        player.prepareToPlay()
        player.delegate = self
        play()
        Progress.stopProgress()
        Progress.stopProgress()
    }

    private func playerBeginInterruption(_ player: AVAudioPlayer) {
        pause()
    }
    
    private func playerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        play()
    }
    
    func play() {
        guard let player = player else {
            return
        }
        m_queue.async {
        self.viewController?.loading(false)
        switch (self.status) {
        case .Pause(0),.Play(0):
            player.play()
            self.status = .Play(0)
        case .Pause(1),.Play(1):
            player.play()
            self.status = .Play(1)
        case .Loading(0):
            player.play()
            self.status = .Play(0)
        case .Loading(1):
            player.play()
            self.status = .Play(1)
        default:
            self.status = .Stop
        }
        self.viewController?.updateToggle()
        }
    }
    
    func pause() {
        guard let player = player else {
            return
        }
        player.pause()
        switch (status) {
        case .Play(0):
            status = .Pause(0)
        case .Play(1):
            status = .Pause(1)
        default:
            break
        }
    }
    
    func stop() {
        guard let player = player else {
            return
        }
        m_queue.async {
            self.status = .Stop
            player.stop()
            self.viewController?.updateToggle()
        }
    }
    
    func incrCurrentIndex(_ i:Int) -> Bool {
        switch (status) {
        case .Play(0), .Pause(0), .Loading(0):
            return (L_Index + i < L_Playlist.count)
        case .Play(1), .Pause(1), .Loading(1):
            return (O_Index + i < O_Playlist.count)
        default:
            return false
        }
    }
    
    func skipToNextItem(_ i:Int) {
        switch (status) {
        case .Pause(0),.Play(0),.Loading(0) :
            guard incrCurrentIndex(i) else {
                switch (mode) {
                case .Shuffle:
                    L_Index = 0
                    O_Index = 0
                    skipToNextItem(1)
                default:
                    Progress.showMessage("最後の曲です")
                    stop()
                }
                return
            }
            L_Index += i
            let url = L_Playlist[L_Index]
            let id = L_PlaylistDict[url]!
            usersong = realm.object(ofType: UserSong.self, forPrimaryKey: id)
        case .Pause(1),.Play(1),.Loading(1):
            guard incrCurrentIndex(i) else {
                //stop()
                return // Task:はじめに戻る　or 終了
            }
            O_Index += i
            let url = O_Playlist[O_Index]
            let id = O_PlaylistDict[url]!
            othersong = realm.object(ofType: OtherSong.self, forPrimaryKey: id)
        default: break
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
}

extension AudioPlayer: AVAudioPlayerDelegate {

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
    /// Did finish. Finish means when music ended not when calling stop
    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        switch mode {
        case .Repeat:
            skipToNextItem(0)
        default:
            skipToNextItem(1)
        }
    }
    
    /// Decoding error
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("DECODE ERROR")
        if let error = error {
            print(error.localizedDescription)
        }
    }
}


