//
//  JPopViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/10.
//  Copyright © 2016年 Gen. All rights reserved.
//

//27
import Foundation
import UIKit
import RealmSwift

class JPopViewController: D_BasePageMenuController {

    class func instantiateFromStoryboard() -> JPopViewController {
        let storyboard = UIStoryboard(name: "GenreViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! JPopViewController
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.loadPlaylistData()
        self.tableView.reloadData()
    }

}

extension JPopViewController {
    func loadPlaylistData() {
        self.playlist.removeAll()

        var Songs: [Song] = []
        let realmResponse = realm.objects(Song.self).filter("genre == '27' && have == false")
        for result in realmResponse {
            Songs.append(result)
        }
        self.playlist = Songs//.sorted(by: {$0.0.title < $0.1.title} )
        self.tableView.reloadData()
    }
}
