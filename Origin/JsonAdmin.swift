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

class JsonAdmin: NSObject {
    
    weak var viewController:MainViewController?

    let url:String = "http://127.0.0.1:8000/api/v1/books/"
    let m_queue = DispatchQueue.main
    
    var tableTitle = [String]()
    var tableDetail = [String]()
    var tableDict:[String:String] = [:]
    
    func loadData(tableView:UITableView) {
        Alamofire.request(url, encoding: JSONEncoding.default).responseJSON {
            response in
            
            guard let value = response.result.value else {
                return
            }
            let json = JSON(value)
            print("json:\(json)")
            let books = json["books"]
            print("books:\(books)")
           
            for item in books.arrayValue {
                self.tableTitle.append(item["name"].stringValue)
                self.tableDetail.append(item["publisher"].stringValue)
            }
            
            print(self.tableTitle)
            print(self.tableDetail)
            
            self.m_queue.async {
                tableView.reloadData()
            }
        }
    }
    
    /*
    / getResponse() {
        Alamofire.request(url).responseJSON { response in
            
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
            debugPrint(response)
            
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
    }*/
    
    
    
    
    
}

