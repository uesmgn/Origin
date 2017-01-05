//
//  HomeViewController.swift
//  Origin
//
//  Created by Gen on 2016/11/26.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit
import PagingMenuController

class HomeViewController: UIViewController {

    var options: PagingMenuControllerCustomizable {
        return H_PagingMenuOption()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.setup(options)

    }

}
