//
//  iTunesAPIClient.swift
//  Origin
//
//  Created by Gen on 2016/12/03.
//  Copyright © 2016年 Gen. All rights reserved.
//
import APIKit

// Define request protocol
// Requestに沿った設計
protocol iTunesRequest: Request {
    
}

// http://itunes.apple.com/search?term=chainsmorkers&limit=10&country=jp
extension iTunesRequest {
    var baseURL: URL {
        return URL(string: "http://itunes.apple.com")!
    }
}

struct GetSearchRequest: iTunesRequest {
    
    typealias Response = [Song]
    
    var method: HTTPMethod {
        return .get
    }
    
    let term: String
    
    init(term: String) {
        self.term = term
    }
    
    var path: String {
        return "/search"
    }
    
    var parameters: Any? {
        return [
            "term": term,
            "limit": 20,
            "country": "jp",
            "media": "music",
            "lang": "ja_jp"
        ]
    }
    
    func response(from object: Any, urlResponse: HTTPURLResponse) throws -> Response {
        var Songs = [Song]()
        print(object)
        let obj = object as! [String : Any]
        if let dictionaries = obj["results"] as? [NSDictionary] {
            for dictionary in dictionaries {
                let song = Song()
                song.itunesId = dictionary["trackId"] as! Int
                song.title = dictionary["trackName"] as? String ?? "unknown"
                song.artwork = dictionary["artworkUrl100"] as? String ?? "unknown"
                song.artist = dictionary["artistName"] as? String ?? "unknown"
                song.album = dictionary["collectionName"] as? String ?? "unknown"
                song.trackSource = dictionary["previewUrl"] as? String ?? "unknown"
                song.rating = 0
                Songs.append(song)
            }
        }
        return Songs
    }
}
