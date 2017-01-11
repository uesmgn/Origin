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
import KDEAudioPlayer

class SongsViewController: UITableViewController {

    let realm = try! Realm()
    var library = [Song]()
    let shared = AudioManager.shared

    class func instantiateFromStoryboard() -> SongsViewController {
        let storyboard = UIStoryboard(name: "MenuViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! SongsViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.reload(_:)), name: NSNotification.Name(key: .UpdateSongMenu), object: nil)

        self.tableView.delegate = self
        self.tableView.dataSource = self

        loadTable()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension SongsViewController {
    // 初回起動時に実行
    func reload(_ notify: NSNotification) {
        // メインスレッドで実行しないとエラー
        DispatchQueue.main.async {
            if library.count != 0 {
                self.tableView.reloadData()
            } else {
                self.loadTable()
            }
        }
    }

    func loadTable() {
        let realmResponse = self.realm.objects(Song.self)
        if realmResponse.count == 0 {
            Progress.stopProgress()
            Progress.showAlert("楽曲が読み込めませんでした")
        } else {
            var songs: [Song] = []
            for result in realmResponse {
                songs.append(result)
            }
            self.library = songs.sorted(by: {$0.0.title < $0.1.title})
            self.tableView.reloadData()
        }
    }
}

extension SongsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.library.count
    }

    // MARK: - UITableViewDelegate

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "songstablecell", for: indexPath) as! SongsTableCell
        let song = library[indexPath.row]
        cell.set(item: song.audioItem!)
        cell.currentItem = shared.currentItem
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let song = library[indexPath.row]
        shared.play(song.audioItem!)
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40.0
    }
}
