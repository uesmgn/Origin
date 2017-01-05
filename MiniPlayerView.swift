//
//  MiniPlayerView.swift
//  Origin
//
//  Created by Gen on 2016/12/26.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import UIKit
import Spring
import Cosmos
import MarqueeLabel

@IBDesignable class MiniPlayerView: UIView, XibInstantiatable {

    @IBOutlet weak var titleLabel: MarqueeLabel!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var toggleButton: SpringButton!
    @IBOutlet weak var modeButton: SpringButton!
    @IBOutlet weak var knownButton: SpringButton!
    @IBOutlet weak var cosmos: CosmosView!

    @IBInspectable var title: String = "title" {
        didSet { self.titleLabel.text = title }
    }
    @IBInspectable var titleColor: UIColor = .lightGray {
        didSet { self.titleLabel.textColor = titleColor }
    }

    enum Mode { case Shuffle, Repeat, Stream }

    enum State { case playing, paused }

    open var didFinishRating: ((Double) -> Void)?
    open var didChangeMode: ((Mode) -> Void)?
    open var didChangeState: ((State) -> Void)?
    open var didChangeKnown: ((Bool) -> Void)?

    @IBAction private func onMode(_ sender: Any) {
        switch (mode) {
        case .Shuffle:
            self.mode = .Repeat
        case .Repeat:
            self.mode = .Stream
        case .Stream:
            self.mode = .Shuffle
        }
        didChangeMode?(self.mode)
    }

    @IBAction private func onKnown(_ sender: Any) {
        self.isKnown = !self.isKnown
        didChangeKnown?(self.isKnown)
    }

    @IBAction private func onToggle(_ sender: Any) {
        switch (state) {
        case .playing:
            self.state = .paused
        case .paused:
            self.state = .playing
        }
        didChangeState?(self.state)
    }

    override func awakeFromNib() {
        instantiate()
        cosmos.didFinishTouchingCosmos = didFinishTouchingCosmos
    }

    private func didFinishTouchingCosmos(_ rating: Double) {
        didFinishRating?(rating)
    }

    // コードから初期化
    override init(frame: CGRect) {
        super.init(frame: frame)
        instantiate()
    }
    // storyboardから初期化
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        instantiate()
    }

    open var rating: Double = 0 {
        didSet { self.cosmos.rating = rating }
    }

    open var state: State = .paused {
        didSet { changeState(state) }
    }

    open var mode: Mode = .Shuffle {
        didSet { changeMode(mode) }
    }

    open var isKnown: Bool = false {
        didSet { changeKnown(isKnown) }
    }

    private func changeState(_ state: State) {
        DispatchQueue.main.async {
            self.toggleButton.animation = "pop"
            switch (state) {
            case .playing:
                self.toggleButton.imageView?.image = UIImage(image: .Player_pause)
            case .paused:
                self.toggleButton.imageView?.image = UIImage(image: .Player_play)
            }
            self.toggleButton.duration = 0.3
            self.toggleButton.animate()
        }
    }

    private func changeMode(_ mode: Mode) {
        DispatchQueue.main.async {
            self.modeButton.animation = "pop"
            switch (mode) {
            case .Shuffle:
                self.modeButton.imageView?.image = UIImage(image: .Shuffle)
            case .Repeat:
                self.modeButton.imageView?.image = UIImage(image: .Repeat)
            case .Stream:
                self.modeButton.imageView?.image = UIImage(image: .Stream)
            }
            self.modeButton.duration = 0.3
            self.modeButton.animate()
        }
    }

    private func changeKnown(_ flag: Bool) {
        DispatchQueue.main.async {
            self.knownButton.animation = "pop"
            if flag {
                self.knownButton.imageView?.image = UIImage(image: .Known)
            } else {
                self.knownButton.imageView?.image = UIImage(image: .Unknown)
            }
            self.knownButton.duration = 0.3
            self.knownButton.animate()
        }
    }

}
