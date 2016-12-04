//
//  LibraryTableViewController.swift
//  Origin
//
//  Created by Gen on 2016/11/26.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit
import PagingMenuController

class LibraryTableViewController: UIViewController/*, UITableViewDelegate, UITableViewDataSource */{

    //@IBOutlet weak var songCountLabel: UILabel!
    //@IBOutlet weak var tableView: UITableView!
    
    var options: PagingMenuControllerCustomizable {
        return PagingMenuOption()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.setup(options)

        //setup(tableView)
        
    }

}
