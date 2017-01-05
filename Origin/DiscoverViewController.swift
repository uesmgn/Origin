//
//  DiscoverViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/10.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit
import PagingMenuController

class DiscoverViewController: UIViewController {

    var options: PagingMenuControllerCustomizable {
        return D_PagingMenuOption()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let pagingMenuController = self.childViewControllers.first as! PagingMenuController
        pagingMenuController.setup(options)

    }

}
