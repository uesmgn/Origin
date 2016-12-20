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
        if let item = usersong, othersong == nil {
            comment = ((item.isKnown == false) ? "\(item.title)を知っていました":"\(item.title)を知りませんでした")
            let request = SaveRatedSongsRequest(item, item.rating, isKnown)
            guard let song = try! request.response() else { return }
            Progress.showMessageWithKnown(isKnown)
            try! realm.write {
                item.isKnown = isKnown
                realm.add(song, update: true)
            }
        } else if let item = othersong, usersong == nil {
            comment = ((item.isKnown == false) ? "\(item.title)を知っていました":"\(item.title)を知りませんでした")
            let request = SaveRatedSongsRequest(item, item.rating, isKnown)
            guard let song = try! request.response() else { return }
            Progress.showMessageWithKnown(isKnown)
            try! realm.write {
                item.isKnown = isKnown
                realm.add(song, update: true)
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
        if let item = usersong, othersong == nil {
            comment = (item.rating == 0) ? "\(item.title)に評価値\(Int(rating))をつけました":"\(item.title)の評価値を\(Int(rating))に更新しました"
            let request = SaveRatedSongsRequest(item, Int(rating), item.isKnown)
            guard let song = try! request.response() else { return }
            Progress.showMessageWithRating(rating)
            try! realm.write {
                item.rating = Int(rating)
                realm.add(song, update: true)
            }
        } else if let item = othersong, usersong == nil {
            comment = (item.rating == 0) ? "\(item.title)に評価値\(Int(rating))をつけました":"\(item.title)の評価値を\(Int(rating))に更新しました"
            let request = SaveRatedSongsRequest(item, Int(rating), item.isKnown)
            guard let song = try! request.response() else { return }
            Progress.showMessageWithRating(rating)
            try! realm.write {
                item.rating = Int(rating)
                realm.add(song, update: true)
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
