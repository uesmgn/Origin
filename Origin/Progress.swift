//
//  Progress.swift
//  Origin
//
//  Created by Gen on 2016/12/06.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import SVProgressHUD


class Progress {
    class func start(){
        SVProgressHUD.setFont(UIFont(name: "HelveticaNeue-Light", size: 14))
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 180))
        SVProgressHUD.show(withStatus: "Loading...")
    }
    
    class func showProgressWithMessage(_ message:String){
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
        SVProgressHUD.setBackgroundColor(UIColor.darkGray)
        SVProgressHUD.show(withStatus: message)
    }
    
    class func showProgress() {
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
        SVProgressHUD.show()
    }
    
    class func stopProgress(){
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
        SVProgressHUD.dismiss()
    }
    
    class func showMessageWithRating(_ rating: Double) {
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
        SVProgressHUD.setMinimumDismissTimeInterval(0.1)
        SVProgressHUD.setFadeOutAnimationDuration(0.3)
        switch rating {
        case 0..<2.5:
            SVProgressHUD.show(UIImage(image: .Dislike), status: "Hate")
        case 3.5..<5.5:
            SVProgressHUD.show(UIImage(image: .Like), status: "Love")
        default:
            SVProgressHUD.show(UIImage(image: .Like), status: "Like")
        }
    }
    
    class func showMessageWithKnown(_ isKnown: Bool) {
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
        SVProgressHUD.setMinimumDismissTimeInterval(0.1)
        SVProgressHUD.setFadeOutAnimationDuration(0.3)
        if isKnown {
            SVProgressHUD.show(UIImage(image: .Success), status: "Known")
        } else {
            SVProgressHUD.show(UIImage(image: .Question), status: "Unknown")
        }
    }
    
    class func  showWithMode(_ mode:AudioPlayer.Mode) {
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
        SVProgressHUD.setMinimumDismissTimeInterval(0.1)
        SVProgressHUD.setFadeOutAnimationDuration(0.3)
        switch (mode) {
        case .Shuffle:
            SVProgressHUD.show(UIImage(image: .Shuffle), status: "Shuffle Mode")
        case .Repeat:
            SVProgressHUD.show(UIImage(image: .Repeat), status: "Repeat Mode")
        case .Stream:
            SVProgressHUD.show(UIImage(image: .Stream), status: "Streaming Mode")
        }
    }
    
    class func showMessage(_ message:String) {
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
        SVProgressHUD.setMinimumDismissTimeInterval(0.1)
        SVProgressHUD.setFadeOutAnimationDuration(0.3)
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    class func showAlert(_ message:String) {
        SVProgressHUD.setOffsetFromCenter(UIOffset(horizontal: 0, vertical: 0))
        SVProgressHUD.setFont(UIFont(name: "HelveticaNeue-Light", size: 14))
        SVProgressHUD.setMinimumDismissTimeInterval(0.1)
        SVProgressHUD.setFadeOutAnimationDuration(0.3)
        SVProgressHUD.showInfo(withStatus: message)
    }
}

    
