//
//  OtherViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/12.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class OtherViewController: D_BasePageMenuController {
    
    class func instantiateFromStoryboard() -> OtherViewController {
        let storyboard = UIStoryboard(name: "GenreViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! OtherViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadPlaylistData()
        self.tableView.reloadData()
    }
    
}

extension OtherViewController {
    func loadPlaylistData() {
        self.playlist.removeAll()
        //["Pop":"14","R&B/Soul":"15","Dance":"17","Hip-Hop/Rap":"18","Alternative":"20","Rock":"21","J-POP":"27"]
        var Songs: [OtherSong] = []
        let predicate = NSPredicate(format: "NOT (genre IN %@)", ["14","17","18","20","21","27","29"])
        let realmResponse = realm.objects(OtherSong.self).filter(predicate)
        for result in realmResponse {
            Songs.append(result)
        }
        self.playlist = Songs//.sorted(by: {$0.0.title < $0.1.title} )
        self.tableView.reloadData()
    }
}
