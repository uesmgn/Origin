//
//  RecommendViewController.swift
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

class RecommendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func tapLoad(_ sender: Any) {
        loadData(tableView: tableView)
    }
    let url:String = "http://127.0.0.1:8000/api/v1/songs/"
    let m_queue = DispatchQueue.main
    
    var tableTitle = [String]()
    var tableDetail = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        loadData(tableView: tableView)
    }
    
    func loadData(tableView:UITableView) {
        
        Alamofire.request(url, encoding: JSONEncoding.default).responseJSON {
            response in
            guard let value = response.result.value else {
                return
            }
            let json = JSON(value)
            print("json:\(json)")
            let songs = json["songs"]
            print("songs:\(songs)")
            
            for item in songs.arrayValue {
                self.tableTitle.append(item["title"].stringValue)
                self.tableDetail.append(item["artist"].stringValue)
            }
            print(self.tableTitle)
            print(self.tableDetail)
            self.tableView.reloadData()
        }
    }
    
    func getResponse() {
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
    
    /*
     Cellが選択された際に呼び出される
     */
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Num: \(indexPath.row)")
        print("Value: \(tableTitle[indexPath.row])")
    }
    
    /*
     Cellの総数を返す.
     */
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableTitle.count
    }
    
    /*
     Cellに値を設定する
     */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        
        // Cellに値を設定する.
        cell.textLabel!.text = "\(tableTitle[indexPath.row])"
        
        return cell
    }
    
}
