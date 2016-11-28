//
//  RecommendViewController.swift
//  Origin
//
//  Created by Gen on 2016/11/28.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit

class RecommendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var jsonAdmin = JsonAdmin()
    
    @IBOutlet weak var tableView: UITableView!
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return jsonAdmin.tableTitle.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        cell.textLabel?.text = jsonAdmin.tableTitle[indexPath.row]
        cell.detailTextLabel?.text = jsonAdmin.tableDetail[indexPath.row]
        return cell
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

}
