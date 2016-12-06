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
    init() {
    }
    
    class func showProgressWithMessage(_ message:String){
        SVProgressHUD.setBackgroundColor(UIColor.darkGray)
        SVProgressHUD.show(withStatus: message)
    }
    
    class func stopProgress(){
        SVProgressHUD.dismiss()
    }
    
    class func showAlertWithRating(_ rating: Double) {
        SVProgressHUD.setBackgroundColor(UIColor.black)
        SVProgressHUD.setMinimumSize(CGSize(width: 100, height: 100))
        SVProgressHUD.setMinimumDismissTimeInterval(0.4)
        switch rating {
        case 0..<2.5:
            SVProgressHUD.show(UIImage(named:"dislike"), status: "Hate")
        case 3.5..<5.5:
            SVProgressHUD.show(UIImage(named:"like"), status: "Love")
        default:
            SVProgressHUD.show(UIImage(named:"like"), status: "Like")
        }
    }
    
    class func stopWithSuccessMessageImg(_ image:UIImage,message:String){
        SVProgressHUD.popActivity()
        SVProgressHUD.show(image, status: message)
    }
    
    class func stopWithErrorMessage(_ message:String){
        SVProgressHUD.popActivity()
        SVProgressHUD.showError(withStatus: message)
    }

}
    
