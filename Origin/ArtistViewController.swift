//
//  ArtistViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/02.
//  Copyright © 2016年 Gen. All rights reserved.
//


import Foundation
import UIKit
import RealmSwift
import MediaPlayer

//
// MARK: - Section Data Structure
//
struct Section {
    var name: String!
    var items: [UserSong]!
    var collapsed: Bool!
    
    init(name: String, items: [UserSong], collapsed: Bool = false) {
        self.name = name
        self.items = items
        self.collapsed = collapsed
    }
}

class ArtistViewController: UITableViewController {
    
    let realm = try! Realm()
    var sectionNameArray:[String] = []
    var sectionElement:[[UserSong]] = []
    let player = AudioPlayer.shared
    
    class func instantiateFromStoryboard() -> ArtistViewController {
        let storyboard = UIStoryboard(name: "MenuViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! ArtistViewController
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
        super.viewDidAppear(animated)    }
    
    func reload(_ notify: NSNotification) {
        //playlist.removeAll()
        // メインスレッドで実行しないとエラー
        DispatchQueue.main.async {
            let realmResponse = self.realm.objects(Artist.self)
            if realmResponse.count == 0 {
                Progress.stopProgress()
                Progress.showAlert("楽曲が読み込めませんでした")
            }
            for results in realmResponse {
                let artistName = results.artistName
                var resultArray:[UserSong] = []
                for result in results.albums {
                    resultArray.append(contentsOf: result.songs)
                }
                let songs = resultArray
                self.sections.append(Section(name: artistName, items: songs))
            }
            self.tableView.reloadData()
        }
    }
    func reloadTable() {
        // ユーザライブラリの曲をlibraryに格納
        let realmResponse = realm.objects(Artist.self)
        for results in realmResponse {
            let artistName = results.artistName
            var resultArray:[UserSong] = []
            for result in results.albums {
                resultArray.append(contentsOf: result.songs)
            }
            let songs = resultArray
            self.sections.append(Section(name: artistName, items: songs))
        }
        self.tableView.reloadData()
    }


}

//
// MARK: - View Controller DataSource and Delegate
//
extension ArtistViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].items.count
    }
    
    // Cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
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
extension ArtistViewController: SectionHeaderDelegate {
    
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
