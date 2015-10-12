
//
//  PAPPhotoCell.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 9/29/15.
//  Copyright © 2015 Xiao Jiang. All rights reserved.
//

import ParseUI

class PAPPhotoCell: PFTableViewCell {
    
    var photoButton: UIButton!
    
    //
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    func setupView() {
        self.opaque = false
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.accessoryType = UITableViewCellAccessoryType.None
        self.clipsToBounds = false
        
        let dropshawdowView = UIView()
        dropshawdowView.backgroundColor = UIColor.whiteColor()
        dropshawdowView.frame = CGRectMake(20.0, -44.0, 280.0, 322.0)
        self.contentView.addSubview(dropshawdowView)

        let layer = dropshawdowView.layer
        layer.masksToBounds = false
        layer.shadowRadius = 3.0
        layer.shadowOpacity = 0.5
        layer.shadowOffset = CGSizeMake(0.0, 1.0)
        layer.shouldRasterize = true
        
        self.imageView?.frame = CGRectMake( 20.0, 0.0, 280.0, 280.0)
        self.imageView?.backgroundColor = UIColor.blackColor()
        self.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
        
        self.photoButton = UIButton(type: UIButtonType.Custom)
        self.photoButton.frame = CGRectMake( 20.0, 0.0, 280.0, 280.0)
        self.photoButton.backgroundColor = UIColor.clearColor()
        self.contentView.addSubview(self.photoButton)
        self.contentView.bringSubviewToFront(self.imageView!)
    }
    
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame = CGRectMake( 0.0, 0.0, (self.superview?.bounds.width)!, 280.0)
        self.photoButton.frame = CGRectMake( 0.0, 0.0, (self.superview?.bounds.width)!, 280.0)
    }

}
