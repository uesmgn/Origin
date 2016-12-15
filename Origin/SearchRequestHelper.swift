//
//  iTunesAPIClient.swift
//  Origin
//
//  Created by Gen on 2016/12/03.
//  Copyright © 2016年 Gen. All rights reserved.
//
import APIKit

// 楽曲検索
protocol iTunesRequest: Request {
}

extension iTunesRequest {
    var baseURL: URL {
        return URL(string: "http://itunes.apple.com")!
    }
}

struct GetSearchRequest: iTunesRequest {
    
    typealias Response = [OtherSong]
    
    var method: HTTPMethod {
        return .get
    }
    
    let term: String
    let limit: Int
    let country: String
    let lang: String
    
    init(term: String, limit: Int = 20, country: String = "jp", lang: String = "ja_jp") {
        self.term = term
        self.limit = limit
        self.country = country
        self.lang = lang
    }
    
    var path: String {
        return "/search"
    }
    
    var parameters: Any? {
        return [
            "term": term,
            "limit": limit,
            "country": country,
            "media": "music",
            "lang": lang
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        var Songs = [OtherSong]()
        let obj = object as! [String : Any]
        if let dictionaries = obj["results"] as? [NSDictionary] {
            for dictionary in dictionaries {
                let song = OtherSong()
                song.itunesId = dictionary["trackId"] as! Int
                song.title = dictionary["trackName"] as? String ?? "unknown"
                song.artwork = dictionary["artworkUrl100"] as? String ?? "unknown"
                song.artistName = dictionary["artistName"] as? String ?? "unknown"
                song.albumTitle = dictionary["collectionName"] as? String ?? "unknown"
                song.trackSource = dictionary["previewUrl"] as? String ?? "unknown"
                song.rating = 0
                Songs.append(song)
            }
        }
        return Songs
    }
}
