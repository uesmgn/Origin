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
    var player: AVAudioPlayer! {
        didSet {
            if !setuped {
                DispatchQueue.main.async {
                    self.setup()
                } 
            }
        }
    }
    
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
    
    override init() {
        self.mode = .Shuffle
        self.status = .Stop
    }
    
    func setup() {
        var array = [String]()
        var idDict = [String:Int]()
        for song in realm.objects(UserSong.self) {
            array.append(song.trackSource)
            idDict[song.trackSource] = song.id
        }
        self.L_Playlist = array
        self.L_PlaylistDict = idDict
        array.removeAll()
        idDict.removeAll()
        for song in realm.objects(OtherSong.self) {
            array.append(song.trackSource)
            idDict[song.trackSource] = song.id
        }
        self.O_Playlist = array
        self.O_PlaylistDict = idDict
        setuped = true
    }
    
    var  Library:[UserSong] {
        var songs: [UserSong] = []
        let realmResponse = realm.objects(UserSong.self)
        for result in realmResponse {
            songs.append(result)
        }
        return songs
    }
    
    var Other:[OtherSong] {
        var songs: [OtherSong] = []
        let realmResponse = realm.objects(OtherSong.self)
        for result in realmResponse {
            songs.append(result)
        }
        return songs
    }
    
    // * Do this method in main thread
    func updatePlaylist() {
        var array = [String]()
        L_Playlist.removeAll()
        O_Playlist.removeAll()
        switch (status) {
            case .Play(0), .Pause(0):
                for song in Library {
                    array.append(song.trackSource)
                }
                L_Playlist = array
            case .Play(1), .Pause(1):
                for song in Other {
                    array.append(song.trackSource)
                }
                O_Playlist = array
            default: break
        }
        if let song = usersong {
            L_Index = L_Playlist.index(of: song.trackSource) ?? 0
        } else if let song = othersong {
            O_Index = O_Playlist.index(of: song.trackSource) ?? 0
        }
        switch (mode) {
            case .Shuffle:
                L_Playlist.shuffle()
                O_Playlist.shuffle()
            default: break
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
    }
    
    var usersong:UserSong? {
        willSet {
            guard let song = self.usersong else {
                return
            }
            DispatchQueue.main.async {
                self.status = .Pause(0)
                self.L_Index = self.L_Playlist.index(of: song.trackSource) ?? 0
                self.updatePlaylist()
                self.viewController.updatePlayinfo()
            }
        }
        didSet {
            guard let song = self.usersong else {
                return
            }
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
    
    var othersong:OtherSong? {
        willSet {
            guard let song = self.othersong else {
                return
            }
            Progress.showProgress()
            DispatchQueue.main.async {
                self.status = .Pause(1)
                self.O_Index = self.O_Playlist.index(of: song.trackSource) ?? 0
                self.updatePlaylist()
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
                    Progress.showAlert("Sorry, missed to play")
                    self.player = nil
                    DispatchQueue.main.async {
                        self.viewController.updatePlayinfo()
                    }
                }
            }
        }
    }
    
    
    func prepareToPlay() {
        if let player = self.player {
            player.prepareToPlay()
            player.delegate = self
            play()
            Progress.stopProgress()
        } else {
            self.status = .Stop
        }
        Progress.stopProgress()
    }

    private func playerBeginInterruption(_ player: AVAudioPlayer) {
        pause()
    }
    
    private func playerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        play()
    }
    
    func play() {
        if let player = player {
            player.play()
            switch (status) {
            case .Pause(0):
                status = .Play(0)
                othersong = nil
            case .Pause(1):
                status = .Play(1)
                usersong = nil
            default:
                status = .Stop
                usersong = nil
                othersong = nil
            }
            DispatchQueue.main.async {
                self.viewController?.updatePlayinfo()
                self.viewController?.updateToggle()
            }
        } else {
            status = .Stop
            usersong = nil
            othersong = nil
        }
    }
    
    func pause() {
        if let player = player {
            player.pause()
            switch (status) {
            case .Play(0):
                status = .Pause(0)
            case .Play(1):
                status = .Pause(1)
            default:
                break
            }
        } else {
            status = .Stop
        }
    }
    
    func stop() {
        status = .Stop
        if let player = player {
            player.stop()
            DispatchQueue.main.async {
                self.viewController?.updatePlayinfo()
                self.viewController?.updateToggle()
            }
        } 
    }
    
    func incrCurrentIndex(_ i:Int) -> Bool {
        switch (status) {
        case .Play(0), .Pause(0):
            return (L_Index + i < L_Playlist.count)
        case .Play(1), .Pause(1):
            return (O_Index + i < O_Playlist.count)
        default:
            return false
        }
    }
    
    func skipToNextItem(_ i:Int) {
        switch (status) {
        case .Play(0), .Pause(0):
            guard incrCurrentIndex(i) else {
                stop()
                return // Task:はじめに戻る　or 終了
            }
            L_Index += i
            let url = L_Playlist[L_Index]
            print(url)
            print(L_PlaylistDict)
            let id = L_PlaylistDict[url]!
            usersong = realm.object(ofType: UserSong.self, forPrimaryKey: id)
        case .Play(1), .Pause(1):
            guard incrCurrentIndex(i) else {
                stop()
                return // Task:はじめに戻る　or 終了
            }
            O_Index += i
            let url = O_Playlist[O_Index]
            let id = O_PlaylistDict[url]!
            othersong = realm.object(ofType: OtherSong.self, forPrimaryKey: id)
        default:
            stop()
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


