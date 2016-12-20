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

class  FirebasePost {
    
    class func post(_ id:Int) {
        let ref = FIRDatabase.database().reference()
        let realm = try! Realm()
        guard let userId = UserDefaults.standard.string(forKey: "uuid") else { return }
        // dictionaryで送信するJSONデータを生成.
        guard let object = realm.object(ofType: RatedSong.self, forPrimaryKey: id) else { return }
        var dicts:[String:Any] = [:]
        dicts = ["title":object.title,"artist":object.artist,"album":object.album,"like":object.rating, "isKnown":object.isKnown]
        let childUpdates = ["/users/\(userId)/songs/\(object.itunesId)": dicts]
        ref.updateChildValues(childUpdates)
    }
    
}
