//
//  CollectionViewController.swift
//  Origin
//
//  Created by Gen on 2016/11/24.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import UIKit
import expanding_collection
import MediaPlayer
import Spring
import RealmSwift

//------------------------------------------
// スクロール型View
//------------------------------------------

class CollectionViewController: ExpandingViewController {
    
    var player = AudioPlayer.shared
    
    var m_queue = DispatchQueue.main
    var s_queue = DispatchQueue(label: "queue")
    
    fileprivate var cellsIsOpen = [Bool]()
    fileprivate var artworkArray = [UIImage]()
    fileprivate var items: [UserSong]?
    
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var toggleButton: SpringButton!
    @IBOutlet weak var currentTitle: UILabel!
    @IBOutlet weak var currentDetail: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    
}

extension CollectionViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(false)
        sclollToCurrentItem(animated: false)
    }
    
    override func viewDidLoad() {
        // セルのサイズ
        itemSize = CGSize(width: 200, height: 200)
        super.viewDidLoad()
        
        self.items = self.player.Library
        // 生成したxibファイルと関連付け
        self.registerCell()
        // cellIsOpen配列に全てfalseを追加
        self.fillCellIsOpenArray()
        // artwork配列にプレイリストの曲のすべてのアートワークをセット
        self.fillArtworkArray()
        // gestureセット
        self.addGestureToView(self.collectionView!)
    
        m_queue.async {
            self.updateToggle()
        }
    }
}


extension CollectionViewController {
    // セルと関連付け
    fileprivate func registerCell() {
        collectionView?.alignmentRect(forFrame: CGRect(x: 0, y: 100, width: 200, height: 200))
        let nib = UINib(nibName: String(describing: CollectionViewCell.self), bundle: nil)
        collectionView?.register(nib, forCellWithReuseIdentifier: String(describing: CollectionViewCell.self))
    }
    
    // cellIsOpen配列セット
    fileprivate func fillCellIsOpenArray() {
        for _ in items! {
            cellsIsOpen.append(false)
        }
    }
    
    // artworkArray配列セット
    fileprivate func fillArtworkArray() {
        let size = CGSize(width: 200, height: 200)
        for song in items! {
            let image = UIImage(data: song.artwork!)
            artworkArray.append(image!)
        }
    }
}

extension CollectionViewController {
    @IBAction func tappedToggleButton(_ sender: Any) {
        toggleButton.animation = "pop"
        if player.isPlaying() {
            m_queue.async {
                self.player.pause()
                self.toggleButton.imageView?.image = UIImage(named: "play")
                self.toggleButton.duration = 0.5
                self.toggleButton.animate()
            }
        } else {
            m_queue.async {
                self.player.play()
                self.toggleButton.imageView?.image = UIImage(named: "pause")
                self.toggleButton.duration = 0.5
                self.toggleButton.animate()
            }
        }

    }
    @IBAction func tapShuffleButton(_ sender: Any) {
    }
    @IBAction func taoRepeatButton(_ sender: Any) {
    }
    
    func sclollToCurrentItem(animated: Bool) {
        if let song = player.nowPlayingItem() as? UserSong {
            let index = player.Library.index(of: song)
            let indexPathOfCurrentItem = IndexPath(item: index!, section: 0)
            collectionView?.scrollToItem(at: indexPathOfCurrentItem, at: UICollectionViewScrollPosition.right, animated: animated)
        }
    }
    
    func updateToggle() {
        if player.isPlaying() {
            self.toggleButton.imageView?.image = UIImage(named: "pause")
        } else {
            self.toggleButton.imageView?.image = UIImage(named: "play")
        }
    }
    
}

extension CollectionViewController {
    // 上下のスワイプをビューに追加
    fileprivate func addGestureToView(_ toView: UIView) {
        
        let gesutereUp = Init(UISwipeGestureRecognizer(target: self, action: #selector(CollectionViewController.swipeHandler(_:)))) {
            $0.direction = .up
        }
        
        let gesutereDown = Init(UISwipeGestureRecognizer(target: self, action: #selector(CollectionViewController.swipeHandler(_:)))) {
            $0.direction = .down
        }
        toView.addGestureRecognizer(gesutereUp)
        toView.addGestureRecognizer(gesutereDown)
    }
    
    func Init<Type>(_ value : Type, block: (_ object: Type) -> Void) -> Type
    {
        block(value)
        return value
    }
    
    
    // cellのスワイプ(上方向，下方向)を監視
    func swipeHandler(_ sender: UISwipeGestureRecognizer) {
        let indexPath = IndexPath(row: currentIndex, section: 0)
        guard let cell  = collectionView?.cellForItem(at: indexPath) as? CollectionViewCell else { return }
        // 上に一回スワイプしたらcellをオープン
        let open = sender.direction == .up ? true : false
        cell.cellIsOpen(open)
        cellsIsOpen[(indexPath as NSIndexPath).row] = cell.isOpened
    }
}

extension CollectionViewController {
    // swiped right or left
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        pageLabel.text = "\(currentIndex+1)/\((items?.count)!)"
        // end cell
        guard currentIndex < (items?.count)! else {
            return
        }
        let song = items?[currentIndex]
        self.currentTitle.text = "\((song?.title)!)"
        self.currentDetail.text = "\((song?.artist)!)-\((song?.album)!)"
    }
    
}

extension CollectionViewController {
    // コレクションビューのセルが見え始めたら実行
    override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        guard let cell = cell as? CollectionViewCell else { return }
        
        //let index = (indexPath as NSIndexPath).row % items.count
        let index = (indexPath as NSIndexPath).row
        let info = items?[index]
        cell.artworkImage?.image = UIImage(data: (info?.artwork)!)
        cell.ratingView.rating = Double(info!.rating)
        cell.cellIsOpen(cellsIsOpen[index], animated: false)
        
    }
    //セルが選択された
    func collectionView(_ collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewCell
            , currentIndex == (indexPath as NSIndexPath).row else { return }
        
        // １回めタップされた
        if cell.isOpened == false {
            cell.cellIsOpen(true)
        }
        // ２回目タップされた
        else {
            cell.cellIsOpen(false)
        }
    }
}

// MARK: UICollectionViewDataSource
extension CollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items!.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let index = indexPath.row
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CollectionViewCell.self), for: indexPath)
        cell.tag = index
        if let song = player.nowPlayingItem() as? UserSong {
            if index == player.Library.index(of: song) {
                collectionView.scrollToItem(at: indexPath, at: UICollectionViewScrollPosition.right, animated: true)
            }
        }
        
        return cell
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        player.usersong = items?[currentIndex]
        player.play()
    }
}






