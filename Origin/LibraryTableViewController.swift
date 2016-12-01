//
//  LibraryTableViewController.swift
//  Origin
//
//  Created by Gen on 2016/11/26.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit

class LibraryTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var songCountLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup(tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.tableView.scrollToNearestSelectedRow(at: UITableViewScrollPosition.top, animated: true)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return musicplayer.playlist.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
        if let song = musicplayer.nowPlayingItem {
            let index = musicplayer.playlist.index(of: song)
            let indexPathOfCurrentItem = IndexPath(item: index!, section: 0)
            tableView.scrollToRow(at: indexPathOfCurrentItem, at: UITableViewScrollPosition.top, animated: animated)
        }
    }
    
    func setup(_ tableView: UITableView) {
        tableView.delegate = self
        tableView.dataSource = self
        musicplayer.libraryTable = self
        tableView.rowHeight = 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let index = (indexPath as NSIndexPath).row
        musicplayer.play(index)
    }
}
