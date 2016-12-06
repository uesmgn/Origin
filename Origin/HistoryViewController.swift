//
//  HistoryViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/06.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    static var shared = HistoryViewController()
    
    @IBOutlet weak var tableView: UITableView!
    
    let realm = try! Realm()
    var playlist = [FavoriteSong]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("history did load")
        // NotificationCenterに登録する。
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.reload(notify:)), name: NSNotification.Name(rawValue: "AddFavorite"), object: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("history did appear")
        playlist.removeAll()
        var Songs: [FavoriteSong] = []
        let realmResponse = realm.objects(FavoriteSong.self)
        for result in realmResponse {
            Songs.append(result)
        }
        self.playlist = Songs.reversed()
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
}

extension HistoryViewController {
    
    func reload(notify: NSNotification) {
        playlist.removeAll()
        var Songs: [FavoriteSong] = []
        let realmResponse = realm.objects(FavoriteSong.self)
        for result in realmResponse {
            Songs.append(result)
        }
        self.playlist = Songs.reversed()
        
        self.tableView.reloadData()
    }
}

extension HistoryViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let nowIndex = (indexPath as NSIndexPath).row
        cell.tag = nowIndex
        let item = playlist[nowIndex]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "\(item.artist)-\(item.album)"
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
        }
    }
}

