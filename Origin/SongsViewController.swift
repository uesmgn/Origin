//
//  SongsViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/04.
//  Copyright © 2016年 Gen. All rights reserved.
//


import Foundation
import UIKit
import RealmSwift
import MediaPlayer

class SongsViewController: UITableViewController {
    
    let realm = try! Realm()
    var playlist = [UserSong]()
    var library:[MPMediaItem] = []
    let player = AudioPlayer.shared
    
    class func instantiateFromStoryboard() -> SongsViewController {
        let storyboard = UIStoryboard(name: "MenuViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! SongsViewController
    }
    
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

extension SongsViewController {
    func loadPlaylistData() {
        playlist.removeAll()
        
        var Songs: [UserSong] = []
        let realmResponse = realm.objects(UserSong.self)
        
        if realmResponse.count != 0 {
            reloadLibrary()
        }
        
        for result in realmResponse {
            Songs.append(result)
        }
        self.playlist = Songs
        self.tableView.reloadData()
    }
    
    
    func reloadLibrary() {
        // ユーザライブラリの曲をlibraryに格納
        let query = MPMediaQuery.songs()
        guard let items = query.items else {
            self.library = []
            print("楽曲が読み込めませんでした")
            return
        }
        self.library = items
        
        let userSongs = realm.objects(UserSong.self)
        if userSongs.count == 0 {
            let request = GetLibraryRequest(library: library)
            let songs = try! request.response()
            for song in songs {
                try! self.realm.write {
                    self.realm.add(song)
                }
            }
        }
    }
}


extension SongsViewController {
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
        cell.detailTextLabel?.text = "\(item.artist)-\(item.album)"
        //cell.imageView?.image = item.artwork?.image(at: CGSize(width: 40.0, height: 40.0)) ?? UIImage(named: "artwork_default")
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = AudioPlayer.shared
        if player.isPlaying() {
            player.pause()
        }
        let song = playlist[indexPath.row]
        print(song.trackSource)
        player.usersong = song
        player.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
        }
    }
    
    
    func sclollToCurrentItem(animated: Bool) {
        if let song = player.nowPlayingItem() as? UserSong {
            let index = player.Library.index(of: song)
            let indexPathOfCurrentItem = IndexPath(item: index!, section: 0)
            tableView.scrollToRow(at: indexPathOfCurrentItem, at: UITableViewScrollPosition.top, animated: animated)
        }
    }
}
