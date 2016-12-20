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
   
    // MARK: Types
   
    /// Notification that is posted when the `skipToNextItem()` is called.
    static let nextTrackNotification = Notification.Name("nextTrackNotification")
    /// Notification that is posted when the `skipToPreviousItem()` is called.
    static let previousTrackNotification = Notification.Name("previousTrackNotification")
    /// Notification that is posted when currently playing `Asset` did change.
    static let currentAssetDidChangeNotification = Notification.Name("currentItemDidChangeNotification")
    /// Notification that is posted when the internal AVPlayer rate did change.
    static let playerRateDidChangeNotification = Notification.Name("playerRateDidChangeNotification")
    /// The progress in percent for the playback of `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    dynamic var percentProgress: Float = 0
    /// The total duration in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    dynamic var duration: Float = 0
    /// The current playback position in seconds for the `asset`.  This is marked as `dynamic` so that this property can be observed using KVO.
    dynamic var playbackPosition: Float = 0
    /// A token obtained from calling `player`'s `addPeriodicTimeObserverForInterval(_:queue:usingBlock:)` method.
    private var timeObserverToken: Any?
    /// The singleton of the player to share throughout the application.
    static let shared = AudioPlayer()
    
    weak var viewController:MainViewController! // Task: revise to notification
    
    /// An enumeration of possible playback states that `AudioPlayer` can be in.
    ///
    /// - Pause(Int): The playback state that `AudioPlayer` is in when a song is selected and being paused.
    /// - Stop: The playback state that `AudioPlayer` is in when deselected an item.
    /// - Loading(Int): The playback state that `AudioPlayer` is in when loading sound data.
    /// - Play(Int): The playback state that `AudioPlayer` is in when a song is selected and being playbacked.
    ///
    /// - Int: 0 when the selected song is in the library, 1 when song is iTunes preview.
    enum Status {
        case Play(Int), Pause(Int), Stop, Loading(Int)
    }
    
    /// An enumeration of possible playback mode that `AudioPlayer` can be in.
    ///
    /// - Shuffle: The playback mode that set after sort playlist at random.
    /// - Stream: The playback mode that playing the song in order of default playlist.
    /// - Repeat: The playback mode that playing the song repeatedly unless operating. If operated the order of playback is the default.
    enum Mode {
        case Shuffle, Stream, Repeat
    }
    
    /// The playback state that the internal 'player' is in.
    /// - Updated information of song metadata when value is rewritten.
    var status:Status = .Stop {
        didSet {
            self.viewController?.updatePlayinfo()
            //self.updateGeneralInfo()
        }
    }
    
    /// The playback mode that the internal 'player' is in.
    var mode:Mode = .Shuffle
    
    /// Selected song as an optional tuple．
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
    
    /// Selected song's ID．
    func nowPlayingItemID() -> Int? {
        switch (status) {
        case .Play(0), .Pause(0), .Loading(0):
            return usersong?.id
        case .Play(1), .Pause(1), .Loading(1):
            return othersong?.id
        default:
            return nil
        }
    }
    
    /// A Bool for tracking playback state
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
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        // Add the notification observer needed to respond to audio interruptions.
        NotificationCenter.default.addObserver(self, selector: #selector(AudioPlayer.handleAVPlayerItemDidPlayToEndTimeNotification(notification:)), name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        // Add the Key-Value Observers needed to keep internal state of `AssetPlaybackManager` and `MPNowPlayingInfoCenter` in sync.
       // player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new], context: nil)
    
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .AVAudioSessionInterruption, object: AVAudioSession.sharedInstance())
        //player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.currentItem), context: nil)
       // player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate), context: nil)
    }
    
    // MARK: Properties
    
    /// The instance of AVAudioPlayer that will be used for playback of usersong and othersong.
    var player: AVAudioPlayer!
    /// The instance of `MPNowPlayingInfoCenter` that is used for updating metadata for the currently playing
    fileprivate let nowPlayingInfoCenter = MPNowPlayingInfoCenter.default()
    /// The instance of `NotificationCenter`
    fileprivate let nc = NotificationCenter.default
    /// The instance of AVAudioPlayer that will be used for data persistence using realm.
    let realm = try! Realm()
    /// Operation queue to be used when switching between usersong and othersong.
    let queue = OperationQueue()
    /// Main queue to be used for UI setting.
    let m_queue = DispatchQueue.main
    /// Global queues used for other purposes.
    let g_queue = DispatchQueue.global()
    /// A Bool for tracking initial setup state
    var setuped:Bool = false
    
    /// Index of the library song that last played
    var L_Index = 0
    /// Index of the iTunes preview that last played
    var O_Index = 0
    /// Array containing the URL of the library songs in order according to mode
    var L_Playlist:[String] = []
    /// Array containing the URL of the iTunes previews in order according to mode
    var O_Playlist:[String] = []
    /// Dictionary associating  url and id(PersistentID) of library songs
    var L_PlaylistDict:[String:Int] = [:]
    /// Dictionary associating  url and id(iTunesID) of iTunes previews
    var O_PlaylistDict:[String:Int] = [:]
    /// Songs of the library stored in the default order
    var Library:[UserSong] = []
    /// Songs of the iTunes preview stored in the default order
    var Other:[OtherSong] = []
    
    /// selected song of library
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
    
    /// selected song of iTunes preview
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
}

extension AudioPlayer {
    // MARK: Key-Value Observing Method
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        print(keyPath ?? "keypath")
        print(object ?? "object")
        print(change ?? "change")
        print(context ?? "context")
    }

    
    // MARK: Notification Observing Methods
    
    func handleAVPlayerItemDidPlayToEndTimeNotification(notification: Notification) {
        //player.replaceCurrentItem(with: nil)
    }
    
    // MARK: MPNowPlayingInforCenter Management Methods

    func updateGeneralInfo() {
        let (usersong, othersong) = self.nowPlayingItem()
        guard (usersong ?? othersong) != nil else {
            return
        }
        var nowPlayingInfo = nowPlayingInfoCenter.nowPlayingInfo ?? [String: Any]()
        
        var title = ""
        var artist = ""
        var album = ""
        var artworkData:Data?
        
        switch (status) {
        case .Loading(0):
            fallthrough
        case .Pause(0), .Play(0):
            if let song = usersong {
                title = song.title
                artist = song.artist
                album = song.album
                artworkData = song.artwork
            }
        case .Loading(1):
            fallthrough
        case .Pause(1), .Play(1):
            if let song = othersong {
                title = song.title
                artist = song.artist
                album = song.album
            }
        default: break
        }
        let image = UIImage(data: artworkData!) ?? UIImage(named: "artwork_default")
        let artwork = MPMediaItemArtwork(boundsSize: (image?.size)!, requestHandler: {  (_) -> UIImage in
                return image!
            })
        nowPlayingInfo[MPMediaItemPropertyTitle] = title
        nowPlayingInfo[MPMediaItemPropertyAlbumTitle] = artist + " - " + album
        nowPlayingInfo[MPMediaItemPropertyArtwork] = artwork
        nowPlayingInfoCenter.nowPlayingInfo = nowPlayingInfo
    }
}

extension AudioPlayer {
    
    // MARK: Private methods.
    
    /// Methods that set default values for the properties to use.
    /// - On first start
    /// - When playback mode changes from shuffle to repeat
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
    
    /// Change play list order when playback mode is changed.
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
    
    /// Change playback mode
    func updateMode(to mode: Mode) {
        self.mode = mode
        Progress.showWithMode(mode)
        updatePlaylist()
    }
}

extension AudioPlayer {
    
    // MARK: Playback Control Methods.
    
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


