//
//  PAPPhotoHeaderView.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 8/30/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse

// We create our own NS_OPTIONS Bitmask Generator
// http://natecook.com/blog/2014/07/swift-options-bitmask-generator/
struct PAPPhotoHeaderButtons : OptionSetType {
    typealias RawValue = UInt
    private var value: UInt = 0
    init(_ value: UInt) { self.value = value }
    init(rawValue value: UInt) { self.value = value }
    init(nilLiteral: ()) { self.value = 0 }
    static var allZeros: PAPPhotoHeaderButtons { return self.init(0) }
    static func fromMask(raw: UInt) -> PAPPhotoHeaderButtons { return self.init(raw) }
    var rawValue: UInt { return self.value }
    
    static var Default: PAPPhotoHeaderButtons { return self.init(0) }
    static var Like: PAPPhotoHeaderButtons { return PAPPhotoHeaderButtons(1 << 0) }
    static var Comment: PAPPhotoHeaderButtons { return PAPPhotoHeaderButtons(1 << 1) }
    static var User: PAPPhotoHeaderButtons { return PAPPhotoHeaderButtons(1 << 2) }
}

/*!
The protocol defines methods a delegate of a PAPPhotoHeaderView should implement.
All methods of the protocol are optional.
*/
@objc protocol PAPPhotoHeaderViewDelegate {
    
    /*!
    Sent to the delegate when the user button is tapped
    @param user the PFUser associated with this button
    */
    optional func photoHeaderView(photoHeaderView: PAPPhotoHeaderView, didTapUserButton button: UIButton, user: PFUser)
    
    
    /*!
    Sent to the delegate when the like photo button is tapped
    @param photo the PFObject for the photo that is being liked or disliked
    */
    optional func photoHeaderView(photoHeaderView: PAPPhotoHeaderView, didTapLikePhotoButton button: UIButton, photo: PFObject)
 
    /*!
    Sent to the delegate when the comment on photo button is tapped
    @param photo the PFObject for the photo that will be commented on
    */
    optional func photoHeaderView(photoHeaderView: PAPPhotoHeaderView, didTapCommentOnPhotoButton button: UIButton, photo: PFObject)
}

@IBDesignable
class PAPPhotoHeaderView: UIView {
    
    var view: UIView!
    
    /// The photo associated with this view
    var photo: PFObject? {
        didSet {
            self.didSetPhoto()
        }
    }
    
    /// The bitmask which specifies the enabled interaction elements in the view
    var headerButtons: PAPPhotoHeaderButtons
    
    /*! @name Accessing Interaction Elements */
    
    /// The Like Photo button
    @IBOutlet var likeButton: UIButton!
    
    /// The Comment On Photo button
    @IBOutlet var commentButton: UIButton!
    
    /*! @name Delegate */
    var delegate: PAPPhotoHeaderViewDelegate?
    
    /// The Avatar Image View
    @IBOutlet var avatarImageView: PAPProfileImageView!
    
    // The User Button
    @IBOutlet var userButton: UIButton!
    
    // The Timestamp Label
    @IBOutlet var timestampLabel: UILabel!
    
    // The time interval formatter
    var timeIntervalFormatter: TTTTimeIntervalFormatter
    
    // MARK: - Initialization
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "PAPPhotoHeaderView", bundle: bundle)
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
        timeIntervalFormatter = TTTTimeIntervalFormatter()
        headerButtons = [PAPPhotoHeaderButtons.Like, PAPPhotoHeaderButtons.Comment, PAPPhotoHeaderButtons.User]
        
        super.init(coder: aDecoder)
        
        self.setupNib()
        
        //self.avatarImageView.profileButton.addTarget(self, action: "didTapUserButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    override init(frame: CGRect) {
        headerButtons = PAPPhotoHeaderButtons.Default
        timeIntervalFormatter = TTTTimeIntervalFormatter()
        
        super.init(frame: frame)
        
    }
    
    /*! @name Creating Photo Header View */
    /*!
        Initializes the view with the specified interaction elements.
        @param buttons A bitmask specifying the interaction elements which are enabled in the view
    */
    convenience init(frame: CGRect, buttons: PAPPhotoHeaderButtons) {
        self.init(frame: frame)
        
        self.headerButtons = buttons
        self.setupNib()
    }
    
    /*! @name Modifying Interaction Elements Status */
    
    /*!
    Configures the Like Button to match the given like status.
    @param liked a BOOL indicating if the associated photo is liked by the user
    */
    func setLikeStatus(liked: Bool) {
        self.likeButton.selected = liked
        
//        if(liked) {
//            [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(-1.0f, 0.0f, 0.0f, 0.0f)];
//            [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, -1.0f)];
//        } else {
//            [self.likeButton setTitleEdgeInsets:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
//            [[self.likeButton titleLabel] setShadowOffset:CGSizeMake(0.0f, 1.0f)];
//        }
    }
    
    /*!
    Enable the like button to start receiving actions.
    @param enable a BOOL indicating if the like button should be enabled.
    */
    func shouldEnableLikeButton(enable: Bool) {
        if(enable) {
            self.likeButton.removeTarget(self, action: "didTapLikePhotoButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        } else {
            self.likeButton.addTarget(self, action: "didTapLikePhotoButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        }
    }
    
    // MARK: - PAPPhotoHeaderView
    
    func didSetPhoto() {
        if let user = self.photo!.objectForKey(kPAPPhotoUserKey) as? PFUser {
            if let profilePictureSmall = user.objectForKey(kPAPUserProfilePicSmallKey) as? PFFile {
                self.avatarImageView.file = profilePictureSmall
            }
            
            let authorName = user.objectForKey(kPAPUserDisplayNameKey) as? String
            self.userButton.setTitle(authorName, forState: UIControlState.Normal)
            
            if(self.headerButtons.intersect(.User) == .User) {
                self.userButton.addTarget(self, action: "didTapUserButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            
            if (self.headerButtons.intersect(.Comment) == .Comment) {
                self.commentButton.addTarget(self, action: "didTapCommentButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            
            if (self.headerButtons.intersect(.Like) == .Like) {
                self.likeButton.addTarget(self, action: "didTapLikeButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            
            // we resize the button to fit the user's name to avoid having a huge touch area
//            CGPoint u≥serButtonPoint = CGPointMake(50.0f, 6.0f);
//            constrainWidth -= userButtonPoint.x;
//            CGSize constrainSize = CGSizeMake(constrainWidth, containerView.bounds.size.height - userButtonPoint.y*2.0f);
//            CGSize userButtonSize = [self.userButton.titleLabel.text sizeWithFont:self.userButton.titleLabel.font constrainedToSize:constrainSize lineBreakMode:UILineBreakModeTailTruncation];
//            CGRect userButtonFrame = CGRectMake(userButtonPoint.x, userButtonPoint.y, userButtonSize.width, userButtonSize.height);
//            [self.userButton setFrame:userButtonFrame];

            if let timeInterval = self.photo?.createdAt?.timeIntervalSinceNow {
                self.timestampLabel.text = self.timeIntervalFormatter.stringForTimeInterval(timeInterval)
                self.setNeedsDisplay()
            }
        }
    }
    
    // MARK: - ()
    
    class func validateButtons(buttons: PAPPhotoHeaderButtons) {
        if(buttons == PAPPhotoHeaderButtons.Default) {
            NSException.raise(NSInvalidArgumentException, format: "Buttons must be set before initializing PAPPhotoHeaderView", arguments: getVaList(["nil"]))
        }
    }
    
    func didTapUserButtonAction(sender: UIButton) {
        if let user = self.photo!.objectForKey(kPAPPhotoUserKey) as? PFUser {
            self.delegate?.photoHeaderView?(self, didTapUserButton: sender, user: user)
        }
    }
    
    func didTapLikeButtonAction(sender: UIButton) {
        self.delegate?.photoHeaderView?(self, didTapLikePhotoButton: sender, photo: self.photo!)
    }
    
    func didTapCommentButtonAction(sender: UIButton) {
        self.delegate?.photoHeaderView?(self, didTapCommentOnPhotoButton: sender, photo: self.photo!)
    }

}
