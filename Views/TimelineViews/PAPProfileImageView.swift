//
//  PAPProfileImageView.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 9/1/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

@IBDesignable
class PAPProfileImageView: UIView {

    @IBOutlet var profileButton: UIButton!
    @IBOutlet var profileImageView: PFImageView!
    @IBOutlet var borderImageView: UIImageView!
    
    @IBInspectable var profileImage: UIImage!
    @IBInspectable var borderImage: UIImage!
    
    var view: UIView!

    // Mark: - Initialization
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "PAPProfileImageView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func nibSetup() {
        self.view = loadViewFromNib()
        self.view.frame = self.bounds
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
        
        self.addSubview(self.view)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.nibSetup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.nibSetup()
    }
    
    // Mark: - View Setup
    
    override func awakeFromNib() {
        setupViews()
    }
    
    override func prepareForInterfaceBuilder() {
        setupViews()
    }
    
    func setupViews() {
        self.profileImageView.image = profileImage
        self.borderImageView.image = borderImage
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.bringSubviewToFront(self.borderImageView)
    }
    
    // MARK: - PAPProfileImageView
    
    func setFile(file: PFFile) {
        self.profileImageView.image = UIImage(named: "AvatarPlaceholder.png")
        self.profileImageView.file = file
        self.profileImageView.loadInBackground()
    }
    
    // TO-Do: Autolayout
}
