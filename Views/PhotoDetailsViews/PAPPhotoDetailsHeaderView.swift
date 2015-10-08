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

let baseHorizontalOffset = 20.0
let baseWidth = 280.0

let horiBorderSpacing = 6.0
let horiMediumSpacing = 8.0

let vertBorderSpacing = 6.0
let vertSmallSpacing = 2.0


let nameHeaderX = baseHorizontalOffset
let nameHeaderY = 0.0
let nameHeaderWidth = baseWidth
let nameHeaderHeight = 46.0

let avatarImageX = horiBorderSpacing
let avatarImageY = vertBorderSpacing
let avatarImageDim = 35.0

let nameLabelX = avatarImageX+avatarImageDim+horiMediumSpacing
let nameLabelY = avatarImageY+vertSmallSpacing
let nameLabelMaxWidth = 280.0 - (horiBorderSpacing+avatarImageDim+horiMediumSpacing+horiBorderSpacing)

let timeLabelX = nameLabelX
let timeLabelMaxWidth = nameLabelMaxWidth

let mainImageX = baseHorizontalOffset
let mainImageY = nameHeaderHeight
let mainImageWidth = baseWidth
let mainImageHeight = 280.0

let likeBarX = baseHorizontalOffset
let likeBarY = nameHeaderHeight + mainImageHeight
let likeBarWidth = baseWidth
let likeBarHeight = 43.0

let likeButtonX = 9.0
let likeButtonY = 7.0
let likeButtonDim = 28.0

let likeProfileXBase = 46.0
let likeProfileXSpace = 3.0
let likeProfileY = 6.0
let likeProfileDim = 30.0

let viewTotalHeight = likeBarY+likeBarHeight
let numLikePics = 7.0

@objc protocol PAPPhotoDetailsHeaderViewDelegate {
    optional func photoDetailsHeaderView(headerView: PAPPhotoDetailsHeaderView, didTapUserButton button: UIButton, user: PFUser)
}

class PAPPhotoDetailsHeaderView: UIView {

    /// The photo displayed in the view
    var photo: PFObject?
    
    /// The user that took the photo
    var photographer: PFUser?
    
    /// Array of the users that liked the photo
    var likeUsers = [PFUser]()
    
    /// Time formatter
    let timeFormatter : TTTTimeIntervalFormatter
    
    /// Heart-shaped like button
    var likeButton: UIButton!
    
    /*! @name Delegate */
    var delegate: PAPPhotoDetailsHeaderViewDelegate?

    var nameHeaderView: UIView!
    
    var photoImageView: PFImageView!
    
    var likeBarView: UIView!
    
    var currentLikeAvatars = [PFObject]()
    
    // MARK: - NSObject
    
    required init(coder aDecoder: NSCoder) {
        timeFormatter = TTTTimeIntervalFormatter()
        
        super.init(coder: aDecoder)!
    }
    
    init(frame: CGRect, photo aPhoto: PFObject) {
        photo = aPhoto
        timeFormatter = TTTTimeIntervalFormatter()
        photographer = aPhoto.objectForKey(kPAPPhotoUserKey) as? PFUser
        
        super.init(frame: frame)
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
        return CGRectMake(0.0, 0.0, UIScreen.mainScreen().bounds.size.width, CGFloat(viewTotalHeight))
    }
    
    // MARK: ()
    func loadData() {
        
//        PFFile *imageFile = [self.photo objectForKey:kPAPPhotoPictureKey];
//        
//        if (imageFile) {
//            self.photoImageView.file = imageFile;
//            [self.photoImageView loadInBackground];
//        }
        self.photographer?.fetchInBackgroundWithBlock({ (object, error) -> Void in
            // Create avatar view
            
        })
    }
    
    func reloadLikeBar() {
//    self.likeUsers = [[PAPCache sharedCache] likersForPhoto:self.photo];
//    [self setLikeButtonState:[[PAPCache sharedCache] isPhotoLikedByCurrentUser:self.photo]];
//    [likeButton addTarget:self action:@selector(didTapLikePhotoButtonAction:) forControlEvents:UIControlEventTouchUpInside];
//    [self setNeedsDisplay];
    }

    
}
