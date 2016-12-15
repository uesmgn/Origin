//
//  TransitionAnimation.swift
//  Origin
//
//  Created by Gen on 2016/11/24.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import UIKit
import ARNTransitionAnimator

// ライブラリ改良
final class TransitionAnimation : TransitionAnimatable {
    
    fileprivate weak var rootVC: MainViewController!
    fileprivate weak var modalVC: CollectionViewController!
    
    var completion: ((Bool) -> Void)?
    
    private var miniPlayerStartFrame: CGRect
    private var tabBarStartFrame: CGRect
    private var navBarStrartFrame: CGRect?
    
    private var containerView: UIView?
    
    deinit {
        print("deinit TransitionAnimation")
    }
    
    init(rootVC: MainViewController, modalVC: CollectionViewController) {
        self.rootVC = rootVC
        self.modalVC = modalVC
        
        self.miniPlayerStartFrame = rootVC.miniPlayerView.frame
        self.tabBarStartFrame = rootVC.tabBar.frame
    }
    
    func prepareContainer(_ transitionType: TransitionType, containerView: UIView, from fromVC: UIViewController, to toVC: UIViewController) {
        self.containerView = containerView
        if transitionType.isPresenting {
            self.rootVC.view.insertSubview(self.modalVC.view, belowSubview: self.rootVC.tabBar)
        } else {
            self.rootVC.view.insertSubview(self.modalVC.view, belowSubview: self.rootVC.tabBar)
        }
        self.rootVC.view.setNeedsLayout()
        self.rootVC.view.layoutIfNeeded()
        self.modalVC.view.setNeedsLayout()
        self.modalVC.view.layoutIfNeeded()
        
        self.miniPlayerStartFrame = self.rootVC.miniPlayerView.frame
        self.tabBarStartFrame = self.rootVC.tabBar.frame
    }
    
    func willAnimation(_ transitionType: TransitionType, containerView: UIView) {
        if transitionType.isPresenting {
            self.rootVC.beginAppearanceTransition(true, animated: false)
            
            self.modalVC.view.frame.origin.y = self.rootVC.miniPlayerView.frame.origin.y + self.rootVC.miniPlayerView.frame.size.height
        } else {
            self.rootVC.beginAppearanceTransition(false, animated: false)
            
            self.rootVC.miniPlayerView.alpha = 1.0
            self.rootVC.miniPlayerView.frame.origin.y = -self.rootVC.miniPlayerView.bounds.size.height
            self.rootVC.tabBar.frame.origin.y = containerView.bounds.size.height
        }
    }
    
    func updateAnimation(_ transitionType: TransitionType, percentComplete: CGFloat) {
        if transitionType.isPresenting {
            // miniPlayerView
            let startOriginY = self.miniPlayerStartFrame.origin.y
            let endOriginY = -self.miniPlayerStartFrame.size.height
            let diff = -endOriginY + startOriginY
            // tabBar
            let tabStartOriginY = self.tabBarStartFrame.origin.y
            let tabEndOriginY = self.modalVC.view.frame.size.height
            let tabDiff = tabEndOriginY - tabStartOriginY
            
            let playerY = startOriginY - (diff * percentComplete)
            self.rootVC.miniPlayerView.frame.origin.y = max(min(playerY, self.miniPlayerStartFrame.origin.y), endOriginY)
            
            self.modalVC.view.frame.origin.y = self.rootVC.miniPlayerView.frame.origin.y + self.rootVC.miniPlayerView.frame.size.height
            let tabY = tabStartOriginY + (tabDiff * percentComplete)
            self.rootVC.tabBar.frame.origin.y = min(max(tabY, self.tabBarStartFrame.origin.y), tabEndOriginY)
            
            let alpha = 1.0 - (1.0 * percentComplete)
            self.rootVC.containerView?.alpha = alpha + 0.5
            self.rootVC.tabBar.alpha = alpha
            self.rootVC.miniPlayerView.subviews.forEach { $0.alpha = alpha }
        } else {
            // miniPlayerView
            let startOriginY = 0 - self.rootVC.miniPlayerView.bounds.size.height
            let endOriginY = self.miniPlayerStartFrame.origin.y
            let diff = -startOriginY + endOriginY
            // tabBar
            // CHANGE: containerView -> view
            let tabStartOriginY = self.rootVC.view.bounds.size.height
            let tabEndOriginY = self.tabBarStartFrame.origin.y
            let tabDiff = tabStartOriginY - tabEndOriginY
            
            self.rootVC.miniPlayerView.frame.origin.y = startOriginY + (diff * percentComplete)
            self.modalVC.view.frame.origin.y = self.rootVC.miniPlayerView.frame.origin.y + self.rootVC.miniPlayerView.frame.size.height
            
            self.rootVC.tabBar.frame.origin.y = tabStartOriginY - (tabDiff *  percentComplete)
            
            let alpha = 1.0 * percentComplete
            self.rootVC.containerView?.alpha = alpha + 0.5
            self.rootVC.tabBar.alpha = alpha
            self.rootVC.miniPlayerView.alpha = 1.0
            self.rootVC.miniPlayerView.subviews.forEach { $0.alpha = alpha }
        }
    }
    
    func finishAnimation(_ transitionType: TransitionType, didComplete: Bool) {
        self.rootVC.endAppearanceTransition()
        
        if transitionType.isPresenting {
            if didComplete {
                self.rootVC.miniPlayerView.alpha = 0.0
                self.modalVC.view.removeFromSuperview()
                self.containerView?.addSubview(self.modalVC.view)
                
                self.completion?(transitionType.isPresenting)
            } else {
                self.rootVC.beginAppearanceTransition(true, animated: false)
                self.rootVC.endAppearanceTransition()
            }
        } else {
            if didComplete {
                self.modalVC.view.removeFromSuperview()
                
                self.completion?(transitionType.isPresenting)
            } else {
                self.rootVC.miniPlayerView.alpha = 0.0
                
                self.modalVC.view.removeFromSuperview()
                self.containerView?.addSubview(self.modalVC.view)
                
                self.rootVC.beginAppearanceTransition(false, animated: false)
                self.rootVC.endAppearanceTransition()
            }
        }
    }
}

extension TransitionAnimation {
    
    func sourceVC() -> UIViewController { return self.rootVC }
    
    func destVC() -> UIViewController { return self.modalVC }
}
