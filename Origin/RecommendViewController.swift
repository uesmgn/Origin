//
//  RecommendViewController.swift
//  Origin
//
//  Created by Gen on 2016/11/28.
//  Copyright © 2016年 Gen. All rights reserved.
//


import Foundation
import UIKit
import RealmSwift

class RecommendViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func tapLoad(_ sender: Any) {
    }
    
    let realm = try! Realm()
    var playlist = [Song]()
    
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

extension RecommendViewController {
    func loadPlaylistData() {
        playlist.removeAll()
        
        var Songs: [Song] = []
        let realmResponse = realm.objects(Song.self)
        for result in realmResponse {
            Songs.append(result)
        }
        self.playlist = Songs.reversed()
        self.tableView.reloadData()
    }
}

extension RecommendViewController {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.playlist.count
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let nowIndex = (indexPath as NSIndexPath).row
        cell.tag = nowIndex
        let item = playlist[nowIndex]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "\(item.artist)-\(item.album)"
        //cell.imageView?.image = item.artwork?.image(at: CGSize(width: 40.0, height: 40.0)) ?? UIImage(named: "artwork_default")
        return cell
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let player = AVAudioPlayerController.shared
        if player.isPlaying() {
            player.pause()
        }
        let song = playlist[indexPath.row]
        print(song.trackSource)
        player.song = song
        player.play()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "detail") {
        }
    }
}
