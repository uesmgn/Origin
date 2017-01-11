//
//  PlaylistView.swift
//  Origin
//
//  Created by Gen on 2017/01/10.
//  Copyright © 2017年 Gen. All rights reserved.
//

import UIKit
import Foundation
import KDEAudioPlayer
import CollectionViewShelfLayout

class PlaylistView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {

    var collectionView: UICollectionView!
    let shared = AudioManager.shared
    var playlist: [AudioItem]?

    // 初期化
    override func awakeFromNib() {
        updateView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        updateView()
    }

    func updateView() {
        // MARK: Layout
        NotificationCenter.default.addObserver(self, selector: #selector(self.reload), name: NSNotification.Name(rawValue: "updateplaylist"), object: nil)
        let shelfLayout = CollectionViewShelfLayout()
        let height = self.frame.size.height
        shelfLayout.cellSize = CGSize(width: height, height: height)
        collectionView = UICollectionView(frame: self.bounds, collectionViewLayout: shelfLayout)
        self.backgroundColor = .clear
        collectionView.backgroundColor = .clear
        self.collectionView.register(UINib(nibName: "PlaylistCell", bundle: nil), forCellWithReuseIdentifier: "playlistcell")
        collectionView.delegate = self
        collectionView.dataSource = self
        self.addSubview(collectionView!)
    }

    func reload() {
        if let items = shared.player.items, let item = shared.player.currentItem {
            let index = Int(items.index(of: item)!)
            let list =  (index+20 < items.count) ? items[index...index+20]:items[index...items.count]
            playlist = list.map { $0 }
        }
        self.collectionView.reloadData()
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        if let playlist =  self.playlist {
            return playlist.count
        }
        return 0
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! PlaylistCell
        if let song = cell.item {
            shared.play(song)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "playlistcell", for: indexPath) as! PlaylistCell
        let index = indexPath.row
        if let item = self.playlist?[index] {
            cell.set(item: item)
            cell.IndexPath = indexPath
        }
        return cell
    }

}
