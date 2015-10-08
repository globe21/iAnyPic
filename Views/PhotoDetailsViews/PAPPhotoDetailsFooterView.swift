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

    var view: UIView!
    
    var hideDropShadow: Bool = false
    
    // MARK: - NSObject
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "PAPPhotoDetailsFooterView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func setupNib() {
        self.view = loadViewFromNib()
        self.view.frame = self.bounds
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
        
        self.addSubview(self.view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setupNib()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupNib()
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
