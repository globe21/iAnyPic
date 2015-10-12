//
//  PAPPhotoDetailsHeaderView.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 9/15/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

@objc protocol PAPPhotoDetailsHeaderViewDelegate {
    optional func photoDetailsHeaderView(headerView: PAPPhotoDetailsHeaderView, didTapUserButton button: UIButton, user: PFUser)
}

class PAPPhotoDetailsHeaderView: UIView {
    
    /// 
    var view: UIView!

    /// The photo displayed in the view
    var photo: PFObject?
    
    /// The user that took the photo
    var photographer: PFUser?
    
    /// Array of the users that liked the photo
    var likeUsers = [PFUser]()
    
    /// Current like avatars
    var currentLikeAvatars = [PFObject]()
    
    /// Time formatter
    let timeFormatter = TTTTimeIntervalFormatter()
    
    /// Heart-shaped like button
    var likeButton: UIButton!
    
    /*! @name Delegate */
    var delegate: PAPPhotoDetailsHeaderViewDelegate?

    @IBOutlet var nameHeaderView: UIView!
    
    @IBOutlet var avatarImageView: PAPProfileImageView!
    
    @IBOutlet var nameButton: UIButton!
    
    @IBOutlet var timeLabel: UILabel!
    
    @IBOutlet var photoImageView: PFImageView!
    
    @IBOutlet var likeBarView: UIView!
    
    
    // MARK: - NSObject
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "PAPPhotoDetailsHeaderView", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func setupNib() {
        self.view = loadViewFromNib()
        self.view.frame = self.bounds
        self.view.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
        
        self.addSubview(self.view)
        
        // Additional Setup
        self.nameHeaderView.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundComments.png")!)
        self.nameButton.addTarget(self, action: "didTapUserNameButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupNib()
    }
    
    init(frame: CGRect, photo aPhoto: PFObject) {
        super.init(frame: frame)
        setupNib()
        
        photo = aPhoto
        photographer = aPhoto.objectForKey(kPAPPhotoUserKey) as? PFUser
        loadData()
    }
    
    convenience init(frame: CGRect, photo: PFObject, photographer: PFUser, likeUsers: [PFUser]) {
        self.init(frame: frame, photo: photo)
        
        self.photographer = photographer
        self.likeUsers = likeUsers
    }
    
    // MARK: - UIView
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        PAPUtility.drawSideDropShadowForRect(self.nameHeaderView.frame, inContext: UIGraphicsGetCurrentContext())
        PAPUtility.drawSideDropShadowForRect(self.photoImageView.frame, inContext: UIGraphicsGetCurrentContext())
        PAPUtility.drawSideDropShadowForRect(self.likeBarView.frame, inContext: UIGraphicsGetCurrentContext())
    }
    
    // MARK: - PAPPhotoDetailsHeaderView
    
    class func rectForView() -> CGRect {
        return CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, CGFloat(369))
    }
    
    func didTapUserNameButtonAction(button: UIButton) {
        self.delegate?.photoDetailsHeaderView?(self, didTapUserButton: button, user: self.photographer!)
    }
    
    // MARK: ()
    func loadData() {
        if let imageFile = self.photo?.objectForKey(kPAPPhotoPictureKey) as? PFFile {
            self.photoImageView.file = imageFile
            self.photoImageView.loadInBackground()
        }
        
        self.photographer?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            
            // Load avatar image
            self.avatarImageView.file = self.photographer?.objectForKey(kPAPUserProfilePicSmallKey) as? PFFile
            self.avatarImageView.profileButton.addTarget(self, action: "didTapUserNameButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            // Setup name button
            let nameString = self.photographer?.objectForKey(kPAPUserDisplayNameKey) as? String
            self.nameButton.setTitle(nameString, forState: UIControlState.Normal)
            self.nameButton.setTitleColor(UIColor(red: 73.0/255.0, green: 55.0/255.0, blue: 35.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
            self.nameButton.setTitleColor(UIColor(red: 134.0/255.0, green: 100.0/255.0, blue: 65.0/255.0, alpha: 1.0), forState: UIControlState.Highlighted)
            
            // Setup time label
            let timeString = self.timeFormatter.stringForTimeIntervalFromDate(NSDate(), toDate: self.photo?.createdAt!)
            self.timeLabel.text = timeString
        })
        
    }
    
    func reloadLikeBar() {
//    self.likeUsers = [[PAPCache sharedCache] likersForPhoto:self.photo];
//    [self setLikeButtonState:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:self.photo]];
//    [likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self setNeedsDisplay];
    }

    
}
