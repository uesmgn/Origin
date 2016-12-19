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
    
    // STATUS
    enum Status {
        case Play(Int) // Library:0 iTunes:1
        case Pause(Int) // Library:0 iTunes:1
        case Stop
    }
    
    enum Mode {
        case Shuffle
        case Repeat
        case Stream
    }
    
    var status:Status
    var mode:Mode
    
    func nowPlayingItem() -> (UserSong?, OtherSong?) {
        if (player) != nil {
            switch (status) {
            case .Play(0), .Pause(0):
                return (usersong, nil)
            case .Play(1), .Pause(1):
                return (nil, othersong)
            default:
                return (nil,nil)
            }
        }
        return (nil,nil)
    }
    
    func isPlaying() -> Bool {
        if let player = player {
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
        switch (mode) {
        case .Shuffle:
            self.mode = .Shuffle
            Progress.showMessage("Shuffle Mode")
        case .Repeat:
            self.mode = .Repeat
            Progress.showMessage("Repeat Mode")
        case .Stream:
            self.mode = .Stream
            Progress.showMessage("Streaming Mode")
        }
        updatePlaylist()
    }
    
    var usersong:UserSong? {
        willSet {
            status = .Pause(0)
            DispatchQueue.main.async {
                self.viewController.updatePlayinfo()
            }
        }
        didSet {
            guard let song = self.usersong else {
                return
            }
            self.L_Index = self.L_Playlist.index(of: song.trackSource) ?? 0
            let url = URL(string: song.trackSource)
            DispatchQueue.global().async {
                do {
                    self.player = try AVAudioPlayer(contentsOf: url!)
                    self.prepareToPlay()
                } catch {
                    Progress.showAlert("Sorry, missed to play")
                    self.player = nil
                    DispatchQueue.main.async {
                        self.viewController.updatePlayinfo()
                    }
                }
            }
        }
    }
    
    let g_queue = DispatchQueue.global()
    
    var othersong:OtherSong? {
        willSet {
            guard let song = self.othersong else {
                return
            }
            status = .Pause(1)
            Progress.showProgress()
            DispatchQueue.main.async {
                self.O_Index = self.O_Playlist.index(of: song.trackSource) ?? 0
                self.viewController.updatePlayinfo()
            }
        }
        didSet {
            guard let song = self.othersong else {
                return
            }
            let url = URL(string: song.trackSource)
            DispatchQueue.global().async {
                do {
                    let soundData = try Data(contentsOf: url!)
                    self.player = try AVAudioPlayer(data: soundData)
                    self.prepareToPlay()
                } catch {
                    Progress.stopProgress()
                    DispatchQueue.main.async {
                        self.viewController.updatePlayinfo()
                    }
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
        player.play()
        switch (status) {
        case .Pause(0),.Play(0):
            status = .Play(0)
            othersong = nil
        case .Pause(1),.Play(1):
            status = .Play(1)
            usersong = nil
        default:
            status = .Stop
            print("1111")
            usersong = nil
            othersong = nil
        }
        DispatchQueue.main.async {
            self.viewController?.updatePlayinfo()
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
        status = .Stop
        print("1113")
        player.stop()
        DispatchQueue.main.async {
            self.viewController?.updatePlayinfo()
            self.viewController?.updateToggle()
        }
    }
    
    func incrCurrentIndex(_ i:Int) -> Bool {
        switch (status) {
        case .Play(0), .Pause(0):
            print("\(L_Index)/\(L_Playlist.count)")
            return (L_Index + i < L_Playlist.count)
        case .Play(1), .Pause(1):
            return (O_Index + i < O_Playlist.count)
        default:
            return false
        }
    }
    
    func skipToNextItem(_ i:Int) {
        switch (status) {
        case .Pause(0),.Play(0) :
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
            print(status)
            L_Index += i
            print("\(L_Index)/\(L_Playlist.count)")
            let url = L_Playlist[L_Index]
            let id = L_PlaylistDict[url]!
            usersong = realm.object(ofType: UserSong.self, forPrimaryKey: id)
        case .Pause(1),.Play(1):
            guard incrCurrentIndex(i) else {
                //stop()
                return // Task:はじめに戻る　or 終了
            }
            O_Index += i
            print("\(O_Index)/\(O_Playlist.count)")
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
        print("finish playing")
        switch mode {
        case .Repeat:
            skipToNextItem(0)
        default:
            skipToNextItem(1)
        }
    }
    
    /// Decoding error
    public func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        }
    }
}


