//
//  HipHopViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/10.
//  Copyright © 2016年 Gen. All rights reserved.
//

//18
import Foundation
import UIKit
import RealmSwift

class HipHopViewController: D_BasePageMenuController {

    class func instantiateFromStoryboard() -> HipHopViewController {
        let storyboard = UIStoryboard(name: "GenreViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! HipHopViewController
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.loadPlaylistData()
        self.tableView.reloadData()
    }

}

extension HipHopViewController {
    func loadPlaylistData() {
        playlist.removeAll()

        var Songs: [Song] = []
        let realmResponse = realm.objects(Song.self).filter("genre == '18' && have == false")
        for result in realmResponse {
            Songs.append(result)
        }
        self.playlist = Songs//.sorted(by: {$0.0.title < $0.1.title} )
        self.tableView.reloadData()
    }
}
