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

class PAPProfileImageView: UIView {

    @IBOutlet var profileButton: UIButton!
    @IBOutlet var profileImageView: PFImageView!
    @IBOutlet var borderImageView: UIImageView!
    
    // MARK: - NSObject
    override func awakeFromNib() {
        super.awakeFromNib()
        
        
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
