//
//  RockViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/10.
//  Copyright © 2016年 Gen. All rights reserved.
//

//21
import Foundation
import UIKit
import RealmSwift

class RockViewController: D_BasePageMenuController {
    
    class func instantiateFromStoryboard() -> RockViewController {
        let storyboard = UIStoryboard(name: "GenreViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! RockViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadPlaylistData()
        self.tableView.reloadData()
    }
    
}

extension RockViewController {
    func loadPlaylistData() {
        playlist.removeAll()
        var Songs: [OtherSong] = []
        let realmResponse = realm.objects(OtherSong.self).filter("genre == '21'")
        for result in realmResponse {
            Songs.append(result)
        }
        self.playlist = Songs//.sorted(by: {$0.0.title < $0.1.title} )
        self.tableView.reloadData()
    }
}
