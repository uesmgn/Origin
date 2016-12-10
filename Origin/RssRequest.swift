//
//  RssRequest2.swift
//  Origin
//
//  Created by Gen on 2016/12/10.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import RealmSwift

protocol RssRequest {
    
    var method: Alamofire.HTTPMethod { get }
    
    var URLString: String { get }
    
    func getRss()
}

extension RssRequest {
    
    var method: HTTPMethod {
        return .get
    }
    
    func getRss() {
        let realm = try! Realm()
        Alamofire.request(URLString, method: method, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                let feed = JSON(object).dictionary?["feed"]
                //let it_link = feed?.dictionary?["link"]?.arrayValue[0].dictionary?["attributes"]?.dictionaryObject?["href"]
                let entries = feed?.dictionary?["entry"]?.arrayValue
                for entry in entries! {
                    let song = OtherSong()
                    song.artistName = (entry["im:artist"].dictionaryObject?["label"] as? String ?? "unknown")!
                    song.artistUrl = (entry["im:artist"].dictionary?["attributes"]?.dictionaryObject?["href"] as? String ?? "unknown")!
                    song.trackSource  = (entry["link"].arrayValue[1].dictionary?["attributes"]?.dictionaryObject?["href"] as? String ?? "unknown")!
                    //releaseDate = entry["im:releaseDate"].dictionaryObject?["label"] as? String
                    song.itunesId = Int(entry["id"].dictionary?["attributes"]?.dictionaryObject?["im:id"] as! String)!
                    song.albumTitle = (entry["im:collection"].dictionary?["im:name"]?.dictionaryObject?["label"] as? String ?? "unknown")!
                    song.artwork = (entry["im:image"].arrayValue[0].dictionaryObject?["label"] as? String ?? "unknown")!
                    song.title = (entry["im:name"].dictionaryObject?["label"] as? String ?? "unknown")!
                    song.genre = (entry["category"].dictionary?["attributes"]?.dictionaryObject?["im:id"] as? String ?? "1")!
                    print(song.genre)
                    if realm.object(ofType: OtherSong.self, forPrimaryKey: song.itunesId) == nil {
                        try! realm.write {
                            realm.add(song)
                        }
                    }
                }
        }
    }
}

struct ALlRssRequest: RssRequest {
    
    var URLString: String {
        return "https://itunes.apple.com/us/rss/topsongs/limit=200/json"
    }
}

struct GenreRssRequest:RssRequest {
    
    var genre:String
    
    init(genre:String) {
        self.genre = genre
    }
    
    var URLString: String {
        return "https://itunes.apple.com/jp/rss/topsongs/genre=\(genre)/limit=20/json"
    }
}
