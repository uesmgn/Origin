//
//  AudioManager.swift
//  Origin
//
//  Created by Gen on 2017/01/05.
//  Copyright © 2017年 Gen. All rights reserved.
//

import Foundation
import AVFoundation
import KDEAudioPlayer

class AudioManager: NSObject, AudioPlayerDelegate {

    static let shared = Audiomanager()

    var player = AudioPlayer()

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

    func play(_ item: AudioItem? = nil) {
        guard let item = item else {
            if let item = player.currentItem {
                // 一時停止中の曲
                if let playlist = playlist {
                    player.play(items: playlist, startAtIndex: playlist.index(of: item)!)
                } else {
                    player.play(item: item)
                }
                self.currentItem = item
            }
            return
        }
        //セルで指定した曲
        if let playlist = playlist {
            player.play(items: playlist, startAtIndex: playlist.index(of: item)!)
        } else {
            player.play(item: item)
        }
        self.currentItem = item
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

    func changeModeTo(_ mode: AudioPlayerMode) {
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
    }

    /// mode cycle: normal -> shuffle -> repeatAll -> repeat ->
    func modeSwitch() {
        let mode = self.player.mode
        switch (mode) {
        case AudioPlayerMode.normal:
            changeModeTo(.shuffle)
        case AudioPlayerMode.shuffle:
            changeModeTo(.repeatAll)
        case AudioPlayerMode.repeatAll:
            changeModeTo(.repeat)
        case AudioPlayerMode.repeat:
            changeModeTo(.normal)
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

    }

    func audioPlayer(_ audioPlayer: AudioPlayer, willStartPlaying item: AudioItem) {

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
