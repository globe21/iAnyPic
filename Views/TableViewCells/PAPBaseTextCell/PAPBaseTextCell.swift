//
//  PAPBaseTextCell.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 10/8/15.
//  Copyright © 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

/*!
The protocol defines methods a delegate of a PAPBaseTextCell should implement.
*/
@objc protocol PAPBaseTextCellDelegate {
    /*!
    Sent to the delegate when a user button is tapped
    @param aUser the PFUser of the user that was tapped
    */
    optional func cell(cellView: PAPBaseTextCell, didTapUserButton aUser: PFUser)
    
}

class PAPBaseTextCell: PFTableViewCell {

    ///
    var mainView: UIView!

    ///
    var delegate: PAPBaseTextCellDelegate?
    
    ///
    var timeFormatter: TTTTimeIntervalFormatter!
    
    ///
    var hideSeparator: Bool = false
    
    /*! The horizontal inset of the cell */
    var cellInsetWidth: CGFloat = 0
    
    /*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
    @IBOutlet var nameButton: UIButton!
    @IBOutlet var avatarImageButton: UIButton!
    @IBOutlet var avatarImageView: PAPProfileImageView!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var separatorImage: UIImageView!
    
    /*! The user represented in the cell */
    var user: PFUser! {
        didSet {
            // Set name button properties and avatar image
            self.avatarImageView.file = user.objectForKey(kPAPUserProfilePicSmallKey) as? PFFile
            self.nameButton.setTitle(user.objectForKey(kPAPUserDisplayNameKey) as? String, forState: UIControlState.Normal)
            self.nameButton.setTitle(user.objectForKey(kPAPUserDisplayNameKey) as? String, forState: UIControlState.Highlighted)
        }
    }
    
    /*! Date when activity is created */
    var date: NSDate? {
        didSet {
            if(date != nil) {
                self.timeLabel.text = timeFormatter.stringForTimeInterval(date!.timeIntervalSinceNow)
            }
        }
    }
    
    /*! */
    var contentText: String? {
        didSet {
           self.contentLabel.text = contentText
        }
    }

    // MARK: - NSObject
    
    func loadViewFromNib() -> UIView {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: "PAPBaseTextCell", bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        
        return view
    }
    
    func setUpNib() {
        self.mainView = loadViewFromNib()
        self.mainView.frame = self.contentView.frame
        self.mainView.autoresizingMask = UIViewAutoresizing.FlexibleWidth.union(UIViewAutoresizing.FlexibleHeight)
        self.contentView.addSubview(self.mainView)
        
        // Additional Initialization
        self.avatarImageButton = self.avatarImageView.profileButton
        
        self.timeFormatter = TTTTimeIntervalFormatter()
        self.mainView.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundComments.png")!)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpNib()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setUpNib()
    }
    
    // MARK: - UIView
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
    }

    // MARK: - UITableViewCell
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Avatar Image Button
        
        // Layout the name button
        
        // Layout the content
        
        // Layout the timestamp label

    }
    
    // MARK: - PAPBaseTextCellDelegate
    
    /* Inform delegate that a user image or name was tapped */
    @IBAction func didTapUserButtonAction(sender: UIButton) {
        if(self.delegate != nil) {
            self.delegate!.cell?(self, didTapUserButton: self.user)
        }
    }
}
