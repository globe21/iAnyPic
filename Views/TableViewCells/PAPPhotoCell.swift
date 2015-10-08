
//
//  PAPPhotoCell.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 9/29/15.
//  Copyright © 2015 Xiao Jiang. All rights reserved.
//

import ParseUI

class PAPPhotoCell: PFTableViewCell {
    
    // 
    let photoButton: UIButton!
    
    //
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        photoButton = UIButton(type: UIButtonType.Custom)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        self.imageView.frame = CGRectMake( 20.0f, 0.0f, 280.0f, 280.0f);
//        self.photoButton.frame = CGRectMake( 20.0f, 0.0f, 280.0f, 280.0f);
    }

}
