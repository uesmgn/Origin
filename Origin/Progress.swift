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
    
    class func showProgressWithMessage(_ message:String){
        SVProgressHUD.setBackgroundColor(UIColor.darkGray)
        SVProgressHUD.show(withStatus: message)
    }
    
    class func stopProgress(){
        SVProgressHUD.dismiss()
    }
    
    class func showAlertWithRating(_ rating: Double) {
        SVProgressHUD.setMinimumDismissTimeInterval(0.1)
        SVProgressHUD.setFadeOutAnimationDuration(0.3)
        switch rating {
        case 0..<2.5:
            SVProgressHUD.show(UIImage(named:"dislike"), status: "Hate")
        case 3.5..<5.5:
            SVProgressHUD.show(UIImage(named:"like"), status: "Love")
        default:
            SVProgressHUD.show(UIImage(named:"like"), status: "Like")
        }
    }
    
    class func showMessage(_ message:String) {
        SVProgressHUD.setMinimumDismissTimeInterval(0.1)
        SVProgressHUD.setFadeOutAnimationDuration(0.3)
        SVProgressHUD.showSuccess(withStatus: message)
    }
    
    class func showAlert(_ message:String) {
        SVProgressHUD.setMinimumDismissTimeInterval(0.1)
        SVProgressHUD.setFadeOutAnimationDuration(0.3)
        SVProgressHUD.showInfo(withStatus: message)
    }
}

    
