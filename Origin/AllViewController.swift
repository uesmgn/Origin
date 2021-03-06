//
//  AllViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/10.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class AllViewController: UITableViewController {
    
    class func instantiateFromStoryboard() -> AllViewController {
        let storyboard = UIStoryboard(name: "GenreViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! AllViewController
    }
    
    let realm = try! Realm()
    var playlist = [OtherSong]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadPlaylistData()
        self.tableView.reloadData()
    }
    
}

extension AllViewController {
    func loadPlaylistData() {
        playlist.removeAll()
        
        var Songs: [OtherSong] = []
        let realmResponse = realm.objects(OtherSong.self)
        for result in realmResponse {
            Songs.append(result)
        }
        self.playlist = Songs//.sorted(by: {$0.0.title < $0.1.title} )
        self.tableView.reloadData()
    }
}

extension AllViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.count
    }
    
    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let nowIndex = (indexPath as NSIndexPath).row
        cell.tag = nowIndex
        let item = playlist[nowIndex]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "\(item.artistName)-\(item.albumTitle)"
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = AudioPlayer.shared
        if player.isPlaying() {
            player.pause()
        }
        let song = playlist[indexPath.row]
        player.song = song
        player.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
        }
    }
}
