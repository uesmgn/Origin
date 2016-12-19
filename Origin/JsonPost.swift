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
        
        
        /*
        var json = ""
        do {
            // Dict -> JSON
            let jsonData = try JSONSerialization.data(withJSONObject: Dictionary, options: .prettyPrinted) //(*)options??
            json = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) as! String
            Progress.showMessage("データを送信しました")
        } catch {
            print("Error!: \(error)")
        }
        let strData = json.data(using: String.Encoding.utf8)
        print(json)*/
        /*request.HTTPBody = strData
        
        do {
            // API POST
            let data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
            
            json = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            
            // JSON -> Dict
            let jsonDict = try NSJSONSerialization.JSONObjectWithData(data, options: []) //(*)options??
            print(jsonDict)
        } catch {
            print("error!: \(error)")
        }*/
        
        /*
        // 作成したdictionaryがJSONに変換可能かチェック.
        if JSONSerialization.isValidJSONObject(Dictionary){
            do {
                // DictionaryからJSON(NSData)へ変換.
                json = try JSONSerialization.data(withJSONObject: Dictionary, options: JSONSerialization.WritingOptions.prettyPrinted) as NSData!
                // 生成したJSONデータの確認.
                print(NSString(data: json as Data, encoding: String.Encoding.utf8.rawValue)!)
                Progress.showMessage("あなたへのプレイリストを読み込みました")
            } catch {
                print(error)
                Progress.showAlert("Error")
            }
        }
        Progress.showAlert("Error")*/
        
        
        /*
        // Http通信のリクエスト生成.
        let config:URLSessionConfiguration = URLSessionConfiguration.default
        let url:NSURL = NSURL(string: "http:/xxx/json_decode.php")!
        let request:NSMutableURLRequest = NSMutableURLRequest(url: url as URL)
        let session:URLSession = URLSession(configuration: config)
        
        request.httpMethod = "POST"
        
        // jsonのデータを一度文字列にして、キーと合わせる.
        let data:NSString = "json=\(NSString(data: json as Data, encoding: String.Encoding.utf8.rawValue)!)" as NSString
        
        // jsonデータのセット.
        request.httpBody = data.data(using: String.Encoding.utf8.rawValue)
        
        let task:URLSessionDataTask = session.dataTask(with: request as URLRequest, completionHandler: { (_data, response, err) -> Void in
            
            // バックグラウンドだとUIの処理が出来ないので、メインスレッドでUIの処理を行わせる.
            DispatchQueue.main.async(execute: {
            })
        })
        
        task.resume()*/
    }
}
