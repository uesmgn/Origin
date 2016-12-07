//
//  SaveFavoriteSongsHelper.swift
//  Origin
//
//  Created by Gen on 2016/12/05.
//  Copyright © 2016年 Gen. All rights reserved.
//

import MediaPlayer
import RealmSwift

protocol SaveFavoriteSongsHelper {
    
    associatedtype Response
    
    func response() throws -> Response
}

struct SaveFavoriteRequest: SaveFavoriteSongsHelper {
    
    typealias Response = FavoriteSong?
    
    var item:Any
    
    init(item:Any) {
        self.item = item
    }
    
    func response() throws -> Response {
        var Songs:FavoriteSong? = nil
        if item as? OtherSong != nil {
            let item = self.item as! OtherSong
            let song = FavoriteSong()
            song.title = item.title
            song.artist = item.artistName
            song.album = item.albumTitle
            song.itunesId = item.itunesId
            song.artwork = UIImagePNGRepresentation(UIImage(named:"artwork_default")!)
            song.rating = item.rating
            song.trackSource = item.trackSource
            Songs = song
        }
        else if item as? UserSong != nil {
            let item = self.item as! UserSong
            let song = FavoriteSong()
            song.title = item.title
            song.artist = item.artistName
            song.album = item.albumTitle
            song.itunesId = item.itunesId
            song.artwork = item.artwork
            song.rating = item.rating
            song.trackSource = item.trackSource
            Songs = song
        }
        return Songs
    }
    
}
