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

// ランキング情報取得
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
                //let it_link = feed?.dictionary?["link"]?.arrayValue[0].dictionary?["attributes"]?.dictionaryObject?["href"]   //iTunesへのリンク
                let entries = feed?.dictionary?["entry"]?.arrayValue
                for entry in entries! {
                    let song = OtherSong()
                    song.artist = (entry["im:artist"].dictionaryObject?["label"] as? String ?? "unknown")!
                    song.artistUrl = (entry["im:artist"].dictionary?["attributes"]?.dictionaryObject?["href"] as? String ?? "unknown")!
                    song.trackSource  = (entry["link"].arrayValue[1].dictionary?["attributes"]?.dictionaryObject?["href"] as? String ?? "unknown")!
                    song.playbackTime = (entry["im:duration"].dictionaryObject?["label"] as? Int ?? 0)!
                    //releaseDate = entry["im:releaseDate"].dictionaryObject?["label"] as? String
                    song.id = Int(entry["id"].dictionary?["attributes"]?.dictionaryObject?["im:id"] as! String)!
                    song.album = (entry["im:collection"].dictionary?["im:name"]?.dictionaryObject?["label"] as? String ?? "unknown")!
                    song.artwork = (entry["im:image"].arrayValue[0].dictionaryObject?["label"] as? String ?? "unknown")!
                    song.title = (entry["im:name"].dictionaryObject?["label"] as? String ?? "unknown")!
                    song.genre = (entry["category"].dictionary?["attributes"]?.dictionaryObject?["im:id"] as? String ?? "1")!
                    // Realmに存在しなかったら追加
                    if realm.object(ofType: OtherSong.self, forPrimaryKey: song.id) == nil {
                        try! realm.write {
                            realm.add(song)
                        }
                    }
                }
        }
    }
}

// 総合ランキング
struct AllRssRequest: RssRequest {
    var URLString: String {
        return "https://itunes.apple.com/jp/rss/topsongs/limit=200/json"
    }
}

// ジャンルごとのランキング
struct GenreRssRequest:RssRequest {
    
    var genre:String
    var limit:Int
    
    init(genre:String, limit:Int = 20) {
        self.genre = genre
        self.limit = limit
    }
    
    var URLString: String {
        return "https://itunes.apple.com/jp/rss/topsongs/genre=\(genre)/limit=\(limit)/json"
    }
}
