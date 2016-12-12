//
//  AlbumViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/02.
//  Copyright © 2016年 Gen. All rights reserved.
//


import Foundation
import UIKit
import RealmSwift
import MediaPlayer

class AlbumViewController: UITableViewController {
    
    let realm = try! Realm()
    var sectionNameArray:[String] = []
    var sectionElement:[[UserSong]] = []
    let player = AudioPlayer.shared
    
    class func instantiateFromStoryboard() -> AlbumViewController {
        let storyboard = UIStoryboard(name: "MenuViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! AlbumViewController
    }
    
    var sections = [Section]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(self.reload(_:)), name: NSNotification.Name(rawValue: "setArtist"), object: nil)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        reloadTable()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func reload(_ notify: NSNotification) {
        //playlist.removeAll()
        // メインスレッドで実行しないとエラー
        DispatchQueue.main.async {
            let realmResponse = self.realm.objects(Album.self)
            if realmResponse.count == 0 {
                Progress.stopProgress()
                Progress.showAlert("楽曲が読み込めませんでした")
            }
            for results in realmResponse {
                let albumTitle = results.albumTitle
                var resultArray:[UserSong] = []
                for result in results.songs {
                    resultArray.append(result)
                }
                let songs = resultArray
                self.sections.append(Section(name: albumTitle, items: songs))
            }
            self.tableView.reloadData()
        }
    }
    func reloadTable() {
        // ユーザライブラリの曲をlibraryに格納
        let realmResponse = realm.objects(Album.self)
        for results in realmResponse {
            let albumTitle = results.albumTitle
            var resultArray:[UserSong] = []
            for result in results.songs {
                resultArray.append(result)
            }
            let songs = resultArray
            self.sections.append(Section(name: albumTitle, items: songs))
        }
        self.tableView.reloadData()
    }
}

//
// MARK: - View Controller DataSource and Delegate
//
extension AlbumViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell? ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
        let song = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = song.title
        cell.detailTextLabel?.text = song.album
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return sections[(indexPath as NSIndexPath).section].collapsed! ? 0 : 40.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = AudioPlayer.shared
        if player.isPlaying() {
            player.pause()
        }
        let song = sections[(indexPath as NSIndexPath).section].items[(indexPath as NSIndexPath).row]
        print(song.trackSource)
        player.usersong = song
        player.play()
    }
    
    // Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeader ?? SectionHeader(reuseIdentifier: "header")
        
        header.titleLabel.text = sections[section].name
        header.arrowLabel.text = ">"
        header.setCollapsed(sections[section].collapsed)
        
        header.section = section
        header.delegate = self
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 32.0
    }
        
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1.0
    }
    
}

//
// MARK: - Section Header Delegate
//
extension AlbumViewController: SectionHeaderDelegate {
    
    func toggleSection(_ header: SectionHeader, section: Int) {
        let collapsed = !sections[section].collapsed
        
        // Toggle collapse
        sections[section].collapsed = collapsed
        header.setCollapsed(collapsed)
        
        // Adjust the height of the rows inside the section
        tableView.beginUpdates()
        for i in 0 ..< sections[section].items.count {
            tableView.reloadRows(at: [IndexPath(row: i, section: section)], with: .automatic)
        }
        tableView.endUpdates()
    }
    
}
