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

//------------------------------------------
// スクロール型View
//------------------------------------------

class CollectionViewController: ExpandingViewController {
    
    var m_queue = DispatchQueue.main
    var s_queue = DispatchQueue(label: "queue")
    
    fileprivate var cellsIsOpen = [Bool]()
    fileprivate var artworkArray = [UIImage]()
    fileprivate var items: [MPMediaItem]?
    fileprivate var ratingDict: [MPMediaItem:Double]?
    fileprivate var isKnownDict: [MPMediaItem:Bool]?
    
    @IBOutlet weak var navBar: UIView!
    @IBOutlet weak var toggleButton: SpringButton!
    @IBOutlet weak var currentTitle: UILabel!
    @IBOutlet weak var currentDetail: UILabel!
    @IBOutlet weak var pageLabel: UILabel!
    @IBOutlet weak var shuffleButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    
}

extension CollectionViewController {
    override func viewDidLoad() {
        // セルのサイズ
        itemSize = CGSize(width: 200, height: 200)
        super.viewDidLoad()
        s_queue.sync {
            items = musicplayer.playlist
        }
        s_queue.sync {
            // 生成したxibファイルと関連付け
            registerCell()
            // cellIsOpen配列に全てfalseを追加
            fillCellIsOpenArray()
            // artwork配列にプレイリストの曲のすべてのアートワークをセット
            fillArtworkArray()
            // gestureセット
            addGestureToView(collectionView!)
        }
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
            let image = song.artwork?.image(at: size)  ?? UIImage(named: "artwork_default")
            artworkArray.append(image!)
        }
    }
}

extension CollectionViewController {
    @IBAction func tappedToggleButton(_ sender: Any) {
        toggleButton.animation = "pop"
        if musicplayer.isPlaying() {
            m_queue.async {
                musicplayer.pause()
                self.toggleButton.imageView?.image = UIImage(named: "play")
                self.toggleButton.duration = 0.5
                self.toggleButton.animate()
            }
        } else {
            m_queue.async {
                musicplayer.play()
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
    
    func updateToggle() {
        if musicplayer.isPlaying() {
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
        print("first")/**/
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
        m_queue.async {
            self.currentTitle.text = "\((song?.title)!)"
            self.currentDetail.text = "\((song?.artist)!)-\((song?.albumTitle)!)"
        }
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
        cell.artworkImage?.image = info?.artwork?.image(at: CGSize(width: 200, height: 200)) ?? UIImage(named: "artwork_default")
        cell.ratingView.rating = 3
       // cell.inKnown.text = "unknown"
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
        return collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: CollectionViewCell.self), for: indexPath)
    }

    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        super.scrollViewDidEndDecelerating(scrollView)
        musicplayer.nowPlayingItem = items?[currentIndex]
    }
}






