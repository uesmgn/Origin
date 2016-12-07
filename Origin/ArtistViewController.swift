//
//  ArtistViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/02.
//  Copyright © 2016年 Gen. All rights reserved.
//


import UIKit
//
// MARK: - Section Data Structure
//
struct Section {
    var name: String!
    var items: [String]!
    var collapsed: Bool!
    
    init(name: String, items: [String], collapsed: Bool = false) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}

class ArtistViewController: UITableViewController {
    
    class func instantiateFromStoryboard() -> ArtistViewController {
        let storyboard = UIStoryboard(name: "MenuViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! ArtistViewController
    }
    
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Apple Products"
        
        // Initialize the sections array
        // Here we have three sections: Mac, iPad, iPhone
        sections = [
            Section(name: "Mac", items: ["MacBook", "MacBook Air", "MacBook Pro", "iMac", "Mac Pro", "Mac mini", "Accessories", "OS X El Capitan"]),
            Section(name: "iPad", items: ["iPad Pro", "iPad Air 2", "iPad mini 4", "Accessories"]),
            Section(name: "iPhone", items: ["iPhone 6s", "iPhone 6", "iPhone SE", "Accessories"]),
        ]
    }
    
}

//
// MARK: - View Controller DataSource and Delegate
//
extension ArtistViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell? ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        
        cell.textLabel?.text = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[(indexPath as NSIndexPath).section].collapsed! ? 0 : 44.0
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ArtistViewHeader ?? ArtistViewHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = sections[section].name
        header.arrowLabel.text = ">"
        header.setCollapsed(sections[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
}

//
// MARK: - Section Header Delegate
//
extension ArtistViewController: ArtistViewHeaderDelegate {
    
    func toggleSection(_ header: ArtistViewHeader, section: Int) {
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Adjust the height of the rows inside the section
        tableView.beginUpdates()
        for i in 0 ..< sections[section].items.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }
    
}
