//
//  AVAudioPlayerController.swift
//  Origin
//
//  Created by Gen on 2016/12/03.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import MediaPlayer

class AVAudioPlayerController: NSObject, AVAudioPlayerDelegate {
    // singleton
    static let shared = AVAudioPlayerController()
    
    var audioPlayer: AVAudioPlayer!
    
    var song:Song? {
        didSet {
            self.initRemoteControl()
            let fileUrl = URL(string: self.song!.trackSource)
            let soundData = try! Data(contentsOf: fileUrl!)
            audioPlayer = try! AVAudioPlayer(data: soundData)
            audioPlayer.delegate = self
            audioPlayer.prepareToPlay()
        }
    }
    
    
    func play() {
        if let audioPlayer = audioPlayer {
            audioPlayer.play()
        }
    }
    
    func stop() {
        if let audioPlayer = audioPlayer {
            audioPlayer.stop()
        }
    }
    
    func pause() {
        if let audioPlayer = audioPlayer {
            audioPlayer.pause()
        }
    }
    
    func pos(_ time: Double) {
        if let audioPlayer = audioPlayer {
            audioPlayer.currentTime = time
        }
    }
    
    func currentTime() -> Double {
        if let audioPlayer = audioPlayer {
            return audioPlayer.currentTime
        }
        return 0.0
    }
    
    func currentTimeStr() -> String {
        if let audioPlayer = audioPlayer {
            let origin = audioPlayer.currentTime
            let min = Int(origin/60)
            let sec = NSString(format: "%02d", Int(origin.truncatingRemainder(dividingBy: 60)))
            return "\(min):\(sec)"
        }
        return "0:00"
    }
    
    func isPlaying() -> Bool {
        if let audioPlayer = audioPlayer {
            return audioPlayer.isPlaying
        }
        return false
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        audioPlayer.stop()
        
        let notification = Notification(name: Notification.Name(rawValue: "finishPlayer"), object: nil)
        NotificationCenter.default.post(notification)
    }
    
    func initRemoteControl() {
        UIApplication.shared.beginReceivingRemoteControlEvents()
        //self.becomeFirstResponder()
        
        do  {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            print("AVAudioSession Category Playback OK")
            do {
                try AVAudioSession.sharedInstance().setActive(true)
                print("AVAudioSession is Active")
            } catch {
                print(error.localizedDescription)
            }
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
}
