//
//  JsonPost.swift
//  Origin
//
//  Created by Gen on 2016/12/13.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit
import RealmSwift
import SwiftyJSON
import Alamofire
import Firebase

class  JsonPost {
    
    let ref = FIRDatabase.database().reference()
    
    func post() {
        
        let realm = try! Realm()
        let userId = UserDefaults.standard.string(forKey: "uuid")
        
        // dictionaryで送信するJSONデータを生成.
        var Dict:[String:Any] = [:]
        let objects = realm.objects(RatedSong.self)
       
        for object in objects {
            var dicts:[String:Any] = [:]
            dicts = ["title":object.title,"artist":object.artist,"album":object.album,"like":object.rating, "isKnown":object.isKnown]
            Dict["\(object.itunesId)"] = dicts
        }
        let childUpdates = ["/users/\(userId!)/songs": Dict]
        ref.updateChildValues(childUpdates)
    }
}
