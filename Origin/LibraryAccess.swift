//
//  LibraryAccessClient.swift
//  Origin
//
//  Created by Gen on 2016/12/04.
//  Copyright © 2016年 Gen. All rights reserved.
//
import MediaPlayer

protocol LibraryAccess {
    
    associatedtype Response
    
    func response() throws -> Response
}

struct GetLibraryRequest: LibraryAccess {
    
    typealias Response = [UserSong]
    
    var library:[MPMediaItem]
    
    init(library:[MPMediaItem]) {
        self.library = library
    }
    
    func response() throws -> Response {
        var Songs = [UserSong]()
        for item in library {
            let song = UserSong()
            song.title = item.title ?? "unknown"
            song.artist = item.artist ?? "unknown"
            song.album = item.albumTitle ?? "unknown"
            song.itunesId = Int(item.persistentID)
            let size = CGSize(width: 100, height: 100)
            song.artwork = UIImagePNGRepresentation(item.artwork?.image(at: size) ?? UIImage(named: "artwork_default")!)
            song.rating = item.rating
            song.trackSource = "\(item.assetURL!)"
            Songs.append(song)
        }
        return Songs
    }

}
