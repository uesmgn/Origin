//
//  player.swift
//  Origin
//
//  Created by Gen on 2016/12/03.
//  Copyright © 2016年 Gen. All rights reserved.
//

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
    
    // status of player
    enum Status {
        case LibraryPlaying
        case PreviewPlaying
    }
    
    enum Mode {
        case Shuffle
        case Repeat
        case Default
    }
    
    var L_Index = 0
    var O_Index = 0
    
    //  song url in playlist
    var L_Playlist:[String]
    var O_Playlist:[String]
    
    var L_PlaylistDict:[String:Int]
    var O_PlaylistDict:[String:Int]
    
    var status:Status
    var mode:Mode
    
    
    // 初期化
    override init() {
        self.mode = .Shuffle
        self.status = .LibraryPlaying
        var array = [String]()
        var dict = [String:Int]()
        for song in realm.objects(UserSong.self) {
            array.append(song.trackSource)
            dict[song.trackSource] = song.id
        }
        self.L_Playlist = array
        self.L_PlaylistDict = dict
        array.removeAll()
        dict.removeAll()
        for song in realm.objects(OtherSong.self) {
            array.append(song.trackSource)
            dict[song.trackSource] = song.itunesId
        }
        self.O_Playlist = array
        self.O_PlaylistDict = dict
    }
    
    var  Library:[UserSong] {
        status = .LibraryPlaying
        var songs: [UserSong] = []
        let realmResponse = realm.objects(UserSong.self)
        for result in realmResponse {
            songs.append(result)
        }
        return songs
    }
    
    var Other:[OtherSong] {
        status = .PreviewPlaying
        var songs: [OtherSong] = []
        let realmResponse = realm.objects(OtherSong.self)
        for result in realmResponse {
            songs.append(result)
        }
        return songs
    }
    
    func updatePlaylist() {
        var array = [String]()
        L_Playlist.removeAll()
        O_Playlist.removeAll()
        switch (status) {
        case .LibraryPlaying:
            for song in Library {
                array.append(song.trackSource)
            }
            L_Playlist = array
        case .PreviewPlaying:
            for song in Other {
                array.append(song.trackSource)
            }
            O_Playlist = array
        }
        switch (mode) {
        case .Shuffle:
            L_Playlist.shuffle()
            O_Playlist.shuffle()
        default: break
        }
    }
    
    var libraryIndex:Int = 0
    var otherIndex:Int = 0
    
    var usersong:UserSong? {
        didSet {
            let url = usersong!.trackSource
            let playlist = L_Playlist
            libraryIndex = playlist.index(of: url) ?? 0
            status = .LibraryPlaying
            self.initRemoteControl()
            if let fileUrl = URL(string: url) {
                do {
                    player = try AVAudioPlayer(contentsOf: fileUrl)
                } catch {
                    player = nil
                    Progress.showAlert("再生に失敗しました")
                    viewController?.updatePlayinfo()
                }
            }
            player.delegate = self
            player.prepareToPlay()
            viewController?.updatePlayinfo()
            play()
        }
    }
    
    var othersong:OtherSong? {
        didSet {
            let url = othersong!.trackSource
            let playlist = O_Playlist
            if let index = playlist.index(of: url) {
                otherIndex = index
            } else {
                
            }
            status = .PreviewPlaying
            self.initRemoteControl()
            DispatchQueue.global().async {
                if let fileUrl = URL(string: url) {
                    do {
                        let soundData = try Data(contentsOf: fileUrl)
                        self.player = try AVAudioPlayer(data: soundData)
                    } catch {
                        self.player = nil
                        Progress.showAlert("再生に失敗しました")
                        self.viewController?.updatePlayinfo()
                    }
                }
                if self.player != nil {
                    self.player.delegate = self
                    self.player.prepareToPlay()
                    self.play()
                }
            }
        }
    }
    
    private func playerBeginInterruption(_ player: AVAudioPlayer) {
        print("interruption")
        player.pause()
    }
    
    private func playerEndInterruption(_ player: AVAudioPlayer, withOptions flags: Int) {
        print("end interruption")
        player.play()
    }
    
    func play() {
        print("play")
        player.play()
        DispatchQueue.main.async {
            self.viewController?.updatePlayinfo()
            self.viewController?.updateToggle()
        }
    }
    
    func stop() {
        print("stop")
        player.stop()
        DispatchQueue.main.async {
            self.viewController?.updatePlayinfo()
            self.viewController?.updateToggle()
        }
    }
    
    func pause() {
        print("pause")
        player.pause()
    }
    
    func pos(_ time: Double) {
        if let player = player {
            player.currentTime = time
        }
    }
    
    func incrLibraryIndex(_ i:Int) -> Bool {
        if libraryIndex + i < L_Playlist.count {
            return true
        }
        return false
    }
    
    func incrOtherIndex(_ i:Int) -> Bool {
        if otherIndex + i < O_Playlist.count {
            return true
        }
        return false
    }
    
    func skipToNextItem(_ i:Int) {
        switch (status) {
        case .LibraryPlaying:
            guard incrLibraryIndex(i) else {
                stop()
                return // Task:はじめに戻る　or 終了
            }
            libraryIndex += i
            let url = L_Playlist[libraryIndex]
            let id = L_PlaylistDict[url]!
            usersong = realm.object(ofType: UserSong.self, forPrimaryKey: id)
        case .PreviewPlaying:
            guard incrOtherIndex(i) else {
                stop()
                return // Task:はじめに戻る　or 終了
            }
            otherIndex += i
            let url = O_Playlist[otherIndex]
            let id = O_PlaylistDict[url]!
            othersong = realm.object(ofType: OtherSong.self, forPrimaryKey: id)
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
    
    // 再生中の曲
    func nowPlayingItem() -> Any? {
        if player != nil {
            switch (status) {
            case .LibraryPlaying:
                return usersong
            case .PreviewPlaying:
                return othersong
            }
        }
        return nil
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


