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
    var history = [Record]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // NotificationCenterに登録する。
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.reload(notify:)), name: NSNotification.Name(rawValue: "AddHistory"), object: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        history.removeAll()
        var Songs: [Record] = []
        let realmResponse = realm.objects(Record.self)
        for result in realmResponse {
            Songs.append(result)
        }
        self.history = Songs.reversed()
        
        self.tableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
}

extension HistoryViewController {
    
    func reload(notify: NSNotification) {
        history.removeAll()
        var Songs: [Record] = []
        let realmResponse = realm.objects(Record.self)
        for result in realmResponse {
            Songs.append(result)
        }
        self.history = Songs.reversed()
        self.tableView.reloadData()
    }
}

extension HistoryViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.history.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let nowIndex = (indexPath as NSIndexPath).row
        cell.tag = nowIndex
        let item = history[nowIndex]
        cell.textLabel?.text = item.datestring
        cell.detailTextLabel?.text = item.comment
        return cell
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
        }
    }
}

