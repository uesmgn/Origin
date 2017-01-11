//
//  RssRequest2.swift
//  Origin
//
//  Created by Gen on 2016/12/10.
//  Copyright © 2016年 Gen. All rights reserved.
//

// EDITED

import Foundation
import Alamofire
import SwiftyJSON
import KDEAudioPlayer
import RealmSwift

class ItunesRssHelper: NSObject {

    class func createPlaylist() {
        var req = rssRequest()
        req.response()
    }

}

// メディアライブラリーの曲を取得
protocol getRssHelper {
}

struct rssRequest: getRssHelper {

    var URLString: String {
        return "https://itunes.apple.com/jp/rss/topsongs/limit=200/json"
    }

    var method: HTTPMethod {
        return .get
    }

    mutating func response() {
        AudioManager.shared.playlist = []
        Alamofire.request(URLString, method: method, parameters: nil, encoding: JSONEncoding.default, headers: nil)
            .responseJSON { response in
                guard let object = response.result.value else {
                    return
                }
                var Songs = [Song]()
                let feed = JSON(object).dictionary?["feed"]
                let entries = feed?.dictionary?["entry"]?.arrayValue
                for entry in entries! {
                    if let urlString = entry["link"].arrayValue[1].dictionary?["attributes"]?.dictionaryObject?["href"] as? String {
                        let song = Song()
                        song.trackSource = urlString
                        song.title = entry["im:name"].dictionaryObject?["label"] as? String ?? "unknown"
                        song.album = entry["im:collection"].dictionary?["im:name"]?.dictionaryObject?["label"] as? String ?? "unknown"
                        song.artist = entry["im:artist"].dictionaryObject?["label"] as? String ?? "unknown"
                        if let artwork = entry["im:image"].arrayValue[0].dictionaryObject?["label"] as? String {
                            song.artworkUrl = artwork
                        }
                        song.genre = (entry["category"].dictionary?["attributes"]?.dictionaryObject?["im:id"] as? String ?? "1")!
                        song.isKnown = false
                        song.have = false
                        song.rating = 0
                        song.id = entry["id"].dictionary?["attributes"]?.dictionaryObject?["im:id"] as! String
                        Songs.append(song)
                    }
                    DispatchQueue.main.async {
                        let realm = try! Realm()
                        try! realm.write {
                            realm.add(Songs, update: true)
                        }
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updaterss"), object: nil)
                    }
                }
        }
    }

}
