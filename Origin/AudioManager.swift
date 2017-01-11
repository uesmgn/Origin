//
//  AudioManager.swift
//  Origin2.0
//
//  Created by Gen on 2017/01/07.
//  Copyright © 2017年 Gen. All rights reserved.
//

import Foundation
import AVFoundation
import KDEAudioPlayer
import RealmSwift

class AudioManager: NSObject, AudioPlayerDelegate {

    static let shared = AudioManager()

    weak var delegate: MainViewController?
    weak var controll: PlayerView?

    var player = AudioPlayer()

    override init() {
        super.init()
        player.delegate = self
    }

    func initiarize() {
        player.mode = .repeatAll
    }

    var currentItem: AudioItem! {
        didSet {
            guard let index =  player.currentItemIndexInQueue else {
                return
            }
            self.currentIndex = index
        }
    }

    var currentIndex = 0
    var playlist: [AudioItem]?

    func play(_ audioitem: AudioItem? = nil) {
        guard let item = audioitem else {
            if let item = player.currentItem {
                // 一時停止中の曲
                player.resume()
            }
            return
        }
        //セルで指定した曲
        if let playlist = playlist {
            player.play(items: playlist, startAtIndex: playlist.index(of: item)!)
        } else {
            player.play(item: item)
        }
    }

    func pause() {
        player.pause()
    }

    func stop() {
        player.stop() // clear queue
    }

    func skipToNext(_ i: Int = 1) {
        for _ in 0...i {
            player.next()
        }
    }

    func skipToPrevious() {
        player.previous()
    }

    private func changeModeTo(_ mode: AudioPlayerMode) {
        switch (mode) {
        case AudioPlayerMode.normal:
            player.mode = .normal
        case AudioPlayerMode.shuffle:
            player.mode = .shuffle
        case AudioPlayerMode.repeat:
            player.mode = .repeat
        case AudioPlayerMode.repeatAll:
            player.mode = .repeatAll
        default:
            break
        }
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateplaylist"), object: nil)
    }

    /// mode cycle: normal -> shuffle -> repeatAll -> repeat ->
    func modeSwitch() {
        let mode = self.player.mode
        switch (mode) {
        case AudioPlayerMode.normal:
            fallthrough
        case AudioPlayerMode.repeatAll:
            changeModeTo(.shuffle)
        case AudioPlayerMode.shuffle:
            changeModeTo(.repeat)
        case AudioPlayerMode.repeat:
            changeModeTo(.repeatAll)
        default:
            break
        }
    }

    func remoteControlReceived(with event: UIEvent?) {
        if let event = event {
            player.remoteControlReceived(with: event)
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, didChangeStateFrom from: AudioPlayerState,
                     to state: AudioPlayerState) {
        // セルのindicatorの状態を変化
        delegate?.updateCell()
        if state == .playing || state == .paused { controll?.changeState(state) }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, willStartPlaying item: AudioItem) {
        // セルのcurrentItemを変化
        if let playlist = playlist {
            if playlist.contains(item) {
                delegate?.updateCell(item)
                controll?.currentItem = item
                currentItem = item
                currentIndex = playlist.index(of: item) ?? 0
                controll?.updateMetadata()
            }
        }
    }

    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateProgressionTo time: TimeInterval, percentageRead: Float) {

    }

    func audioPlayer(_ audioPlayer: AudioPlayer, didFindDuration duration: TimeInterval, for item: AudioItem) {

    }

    func audioPlayer(_ audioPlayer: AudioPlayer, didUpdateEmptyMetadataOn item: AudioItem, withData data: Metadata) {

    }

    func audioPlayer(_ audioPlayer: AudioPlayer, didLoad range: TimeRange, for item: AudioItem) {

    }
}
