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
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.reload(_:)), name: NSNotification.Name(rawValue: "setLibrary"), object: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if playlist.count == 0 {
            self.reloadTable()
        }
    }
    
}

extension SongsViewController {
    // 初回起動時に実行
    func reload(_ notify: NSNotification) {
        playlist.removeAll()
        // メインスレッドで実行しないとエラー
        DispatchQueue.main.async {
            let realmResponse = self.realm.objects(UserSong.self)
            if realmResponse.count == 0 {
                Progress.stopProgress()
                Progress.showAlert("楽曲が読み込めませんでした")
            }
            for result in realmResponse {
                self.playlist.append(result)
            }
            self.tableView.reloadData()
            Progress.stopProgress()
        }
    }
    
    func reloadTable() {
        // ユーザライブラリの曲をlibraryに格納
        var Songs: [UserSong] = []
        let realmResponse = realm.objects(UserSong.self)
        for result in realmResponse {
            Songs.append(result)
        }
        self.playlist = Songs.sorted(by: {$0.0.title < $0.1.title})
        self.tableView.reloadData()
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
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
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
