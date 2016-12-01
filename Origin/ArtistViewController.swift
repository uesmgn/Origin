//
//  ArtistViewController.swift
//  Origin
//
//  Created by Gen on 2016/12/02.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit

class ArtistViewController: UITableViewController {
    
    class func instantiateFromStoryboard() -> ArtistViewController {
        let storyboard = UIStoryboard(name: "MenuViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: String(describing: self)) as! ArtistViewController
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        musicplayer.artistTable = self
        tableView.rowHeight = 44
        self.tableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.top, animated: true)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        self.tableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.top, animated: true)
        
    }
}

extension ArtistViewController {
    // MARK: - UITableViewDataSource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicplayer.playlist.count
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let nowIndex = (indexPath as NSIndexPath).row
        cell.tag = nowIndex
        let item = musicplayer.playlist[nowIndex]
        cell.textLabel?.text = item.title
        cell.detailTextLabel?.text = "\(item.artist!) - \(item.albumTitle!)"
        //cell.imageView?.image = item.artwork?.image(at: CGSize(width: 40.0, height: 40.0)) ?? UIImage(named: "artwork_default")
        return cell
        
    }
    
    func sclollToCurrentItem(animated: Bool) {
        if let Artist = musicplayer.nowPlayingItem {
            let index = musicplayer.playlist.index(of: Artist)
            let indexPathOfCurrentItem = IndexPath(item: index!, section: 0)
            tableView.scrollToRow(at: indexPathOfCurrentItem, at: UITableViewScrollPosition.top, animated: animated)
        }
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = (indexPath as NSIndexPath).row
        musicplayer.play(index)
    }
}
