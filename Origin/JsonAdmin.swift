//
//  JsonAdmin.swift
//  Origin
//
//  Created by Gen on 2016/11/28.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import Alamofire
import MediaPlayer

// Djangoサーバとの接続
class JsonAdmin: NSObject {
    
    weak var viewController:MainViewController?
    weak var recTable:UITableView?
    
    let m_queue = DispatchQueue.main
    
    var tableDict:[String:String] = [:]
    
    
    var tableTitle = [String]()
    var tableDetail = [String]()
    let url:String = "http://localhost:8000/api/v1/songs/"
    
    func loadData(tableView:UITableView) {
        Alamofire.request(url).responseJSON { response in
            
            guard let value = response.result.value else {
                return
            }
            let json = JSON(value)
            let books = json["books"]
           
            for item in books.arrayValue {
                self.tableTitle.append(item["name"].stringValue)
                self.tableDetail.append(item["publisher"].stringValue)
            }
            
            print(self.tableTitle)
            print(self.tableDetail)
            
            tableView.reloadData()
        }
    }
    
    func getResponse() {
        Alamofire.request(url).responseJSON { response in
            
            print(response.result)
            if let JSON = response.result.value {
                print("JSON: \(JSON)")
            }
        }
    }
    
    func getString() {
        Alamofire.request(url).response { response in
            
            if let data = response.data, let utf8Text = String(data: data, encoding: .utf8) {
                print("Data: \(utf8Text)")
            }
        }
    }
    
    func getStr() {
        Alamofire.request(url).response { response in
            
            if let data = response.data {
                print(data)
            }
        }
    }
    
    func post() {
        Alamofire.request(url, method: .get).response { response in
            
            if let data = response.response {
                print(data)
            }
        }
    }
    
    func getJson() {
        Alamofire.request(url).responseJSON { response in
            
            if let json = response.result.value {
                print("JSON: \(json)")
            }
        }
    }
    
    func getChain() {
        Alamofire.request(url)
            .responseString { response in
                print("Response String: \(response.result.value)")
            }
            .responseJSON { response in
                print("Response JSON: \(response.result.value)")
        }
    }
    
    
    func get() {
        Alamofire.request(url, method: .get, encoding: JSONEncoding.default).responseJSON { response in
            
            guard let json = response.result.value else {
                return
            }
            print(json)
        }
    }
    
    
    
    
    
}

