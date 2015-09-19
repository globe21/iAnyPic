//
//  PAPPhotoDetailsFooterView.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 9/15/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit

class PAPPhotoDetailsFooterView: UIView {

    @IBOutlet var mainView: UIView!
    @IBOutlet var messageIcon: UIImageView!
    @IBOutlet var commentBox: UIImageView!
    @IBOutlet var commentField: UITextField!
    
    var hideDropShadow: Bool = false
    
    // MARK: - NSObject
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        //NSBundle.mainBundle().loadNibNamed("PAPPhotoDetailsFooterView", owner: self, options: nil)
        
        // Add as subview
        //self.addSubview(self.mainView)
        
        // Allow for autolayout
        //self.mainView.setTranslatesAutoresizingMaskIntoConstraints(true)
        
    }
    
    // MARK: - UIView
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        if(!self.hideDropShadow) {
            PAPUtility.drawSideAndBottomDropShadowForRect(self.frame, inContext: UIGraphicsGetCurrentContext())
        }
    }
    
    // MARK: - PAPPhotoDetailsFooterView
    
    class func rectForView() -> CGRect {
        return CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, 69.0)
    }
}
