//
//  LibraryAccessClient.swift
//  Origin
//
//  Created by Gen on 2016/12/04.
//  Copyright © 2016年 Gen. All rights reserved.
//

// EDITED

import Foundation
import MediaPlayer
import KDEAudioPlayer
import RealmSwift

class MediaLibraryHelper: NSObject {

    class func createPlaylist() {
        let query = MPMediaQuery.songs()
        print(query.items?.count)
        if query.items?.count != 0 {
            var Songs = [Song]()
            for item in query.items! {
                let song = Song()
                song.title = item.title ?? "unknown"
                song.album = item.albumTitle ?? "unknown"
                song.artist = item.albumArtist ?? "unknown"
                song.have = true
                song.isKnown = true
                song.rating = 0
                song.artworkData = UIImagePNGRepresentation(item.artwork?.image(at: CGSize(width: 50, height: 50)) ?? UIImage(named: "artwork_default")!)
                song.id = "\(item.persistentID)"
                song.trackSource = "\(item.assetURL!)"
                Songs.append(song)
                print(song)
            }
            DispatchQueue.main.async {
                let realm = try! Realm()
                try! realm.write {
                    realm.add(Songs, update: true)
                }
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updatelibrary"), object: nil)
            }
        }
    }
}
