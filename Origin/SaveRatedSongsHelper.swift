//
//  SaveFavoriteSongsHelper.swift
//  Origin
//
//  Created by Gen on 2016/12/05.
//  Copyright © 2016年 Gen. All rights reserved.
//

import MediaPlayer
import RealmSwift

protocol SaveRatedSongsHelper {
    
    associatedtype Response
    
    func response() throws -> Response
}

struct SaveRatedSongsRequest: SaveRatedSongsHelper {
    
    typealias Response = RatedSong?
    
    var item:Any
    var rating:Int
    var isKnown:Bool
    
    init(_ item:Any, _ rating:Int, _ isKnown:Bool) {
        self.item = item
        self.rating = rating
        self.isKnown = isKnown
    }
    
    func response() throws -> Response {
        var Songs:RatedSong? = nil
        if item as? OtherSong != nil {
            let item = self.item as! OtherSong
            let song = RatedSong()
            song.title = item.title
            song.artist = item.artist
            song.album = item.album
            song.itunesId = item.id
            song.artwork = UIImagePNGRepresentation(UIImage(named:"artwork_default")!)
            song.rating = rating
            song.isKnown = isKnown
            song.trackSource = item.trackSource
            Songs = song
        }
        else if item as? UserSong != nil {
            let item = self.item as! UserSong
            let song = RatedSong()
            song.title = item.title
            song.artist = item.artist
            song.album = item.album
            song.itunesId = item.id
            song.artwork = item.artwork
            song.rating = rating
            song.isKnown = isKnown
            song.trackSource = item.trackSource
            Songs = song
        }
        return Songs
    }
}
