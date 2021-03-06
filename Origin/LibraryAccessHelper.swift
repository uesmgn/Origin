//
//  LibraryAccessClient.swift
//  Origin
//
//  Created by Gen on 2016/12/04.
//  Copyright © 2016年 Gen. All rights reserved.
//
import MediaPlayer
import Foundation
import RealmSwift

// メディアライブラリーの曲を取得
protocol LibraryAccessHelper {
    
    associatedtype Response
    
    func response() throws -> Response
}

struct MediaLibraryRequest: LibraryAccessHelper {
    
    typealias Response = List<Album>
    
    var songQuery = MPMediaQuery.songs()
    var albumCollection:[MPMediaItemCollection]
    
    init() {
        songQuery.groupingType = MPMediaGrouping.album
        self.albumCollection = songQuery.collections!
    }
    
    func response() throws -> Response {
        // アルバムのリストを作成
        let albums = List<Album>()
        
        for collection in albumCollection {
            
            let album = Album()
            let songs = List<UserSong>()
            
            for item in collection.items {
                let song = UserSong()
                song.title = item.title ?? "unknown"
                song.artist = item.albumArtist ?? "unknown"
                song.album = item.albumTitle ?? "unknown"
                let str = "\(item.persistentID)"
                guard let int = Int(str) else {
                    continue
                }
                song.id = int // Task:iTunesID割り当て Int(item.persistentID)+
                let size = CGSize(width: 100, height: 100)
                song.artwork = UIImagePNGRepresentation(item.artwork?.image(at: size) ?? UIImage(named: "artwork_default")!)
                song.rating = 0
                song.playbackTime = item.beatsPerMinute
                song.trackSource = "\(item.assetURL!)"
                songs.append(song)
            }
            let first = collection.items[0]
            album.songs.append(objectsIn: songs)
            album.albumTitle = first.albumTitle ?? "unknown"
            album.artistName = first.albumArtist ?? "unknown"
            let size = CGSize(width: 100, height: 100)
            album.artwork = UIImagePNGRepresentation(first.artwork?.image(at: size) ?? UIImage(named: "artwork_default")!)
            albums.append(album)
            print(album.albumTitle)
        }
        return albums
    }
    
}
