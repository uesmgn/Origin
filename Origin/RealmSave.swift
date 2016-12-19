//
//  Realm.swift
//  Origin
//
//  Created by Gen on 2016/12/19.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import RealmSwift
import AVFoundation

class Save:NSObject {
    
    class func known(_ isKnown:Bool) {
        let realm = try! Realm()
        var comment:String = ""
        let (usersong, othersong) = AudioPlayer.shared.nowPlayingItem()
        if let song = usersong, othersong == nil {
            comment = ((song.isKnown == false) ? "\(song.title)を知っていました":"\(song.title)を知りませんでした")
            Progress.showMessageWithKnown(isKnown)
            let request = SaveRatedSongRequest(item: song)
            let ratedsong = try! request.response()
            try! realm.write {
                song.isKnown = isKnown
                realm.add(ratedsong!, update: true)
            }
        } else if let song = othersong, usersong == nil {
            comment = ((song.isKnown == false) ? "\(song.title)を知っていました":"\(song.title)を知りませんでした")
            Progress.showMessageWithKnown(isKnown)
            let request = SaveRatedSongRequest(item: song)
            let ratedsong = try! request.response()
            try! realm.write {
                song.isKnown = isKnown
                realm.add(ratedsong!, update: true)
            }
        }
        let record = Record()
        try! realm.write {
            record.comment = comment
            record.date = Date()
            realm.add(record)
        }
    }
            
    class func rating(_ rating:Double) {
        let realm = try! Realm()
        var comment:String = ""
        let (usersong, othersong) = AudioPlayer.shared.nowPlayingItem()
        if let song = usersong, othersong == nil {
            comment = (song.rating == 0) ? "\(song.title)に評価値\(Int(rating))をつけました":"\(song.title)の評価値を\(Int(rating))に更新しました"
            Progress.showMessageWithRating(rating)
            let request = SaveRatedSongRequest(item: song)
            let ratedsong = try! request.response()
            try! realm.write {
                song.rating = Int(rating)
                realm.add(ratedsong!, update: true)
            }
        } else if let song = othersong, usersong == nil {
            comment = (song.rating == 0) ? "\(song.title)に評価値\(Int(rating))をつけました":"\(song.title)の評価値を\(Int(rating))に更新しました"
            Progress.showMessageWithRating(rating)
            let request = SaveRatedSongRequest(item: song)
            let ratedsong = try! request.response()
            try! realm.write {
                song.rating = Int(rating)
                realm.add(ratedsong!, update: true)
            }
        }
        let record = Record()
        try! realm.write {
            record.comment = comment
            record.date = Date()
            realm.add(record)
        }
    }
}
