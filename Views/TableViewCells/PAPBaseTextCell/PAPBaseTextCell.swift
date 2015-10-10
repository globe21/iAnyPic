//
//  PAPBaseTextCell.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 10/8/15.
//  Copyright © 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse

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

class PAPBaseTextCell: UITableViewCell {
    
    var delegate: PAPBaseTextCellDelegate?
    
    var timeFormatter: TTTTimeIntervalFormatter!
    
    /*! The user represented in the cell */
    var user: PFUser!
    
    /*! The cell's views. These shouldn't be modified but need to be exposed for the subclass */
    var mainView: UIView!
    var nameButton: UIButton!
    var avatarImageButton: UIButton!
    var avatarImageView: PAPProfileImageView!
    var contentLabel: UILabel!
    var timeLabel: UILabel!
    var hideSeparator: Bool = false
    var separatorImage: UIImageView!
    
    /*! The horizontal inset of the cell */
    var cellInsetWidth: CGFloat = 0


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
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setUpNib()
        
        self.timeFormatter = TTTTimeIntervalFormatter()
        
        self.mainView.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundComments.png")!)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setUpNib()
        self.timeFormatter = TTTTimeIntervalFormatter()

    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Layout the name button
        let nameSize = self.nameButton.titleLabel?.text.
        CGSize nameSize = [self.nameButton.titleLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:13] forWidth:nameMaxWidth lineBreakMode:UILineBreakModeTailTruncation];
        [self.nameButton setFrame:CGRectMake(nameX, nameY, nameSize.width, nameSize.height)];
        
        // Layout the content
        CGSize contentSize = [self.contentLabel.text sizeWithFont:[UIFont systemFontOfSize:13] constrainedToSize:CGSizeMake(horizontalTextSpace, CGFLOAT_MAX) lineBreakMode:UILineBreakModeWordWrap];
        [self.contentLabel setFrame:CGRectMake(nameX, vertTextBorderSpacing, contentSize.width, contentSize.height)];
        
        // Layout the timestamp label
        CGSize timeSize = [self.timeLabel.text sizeWithFont:[UIFont systemFontOfSize:11] forWidth:horizontalTextSpace lineBreakMode:UILineBreakModeTailTruncation];
        [self.timeLabel setFrame:CGRectMake(timeX, contentLabel.frame.origin.y + contentLabel.frame.size.height + vertElemSpacing, timeSize.width, timeSize.height)];

    }
    
    // MARK: - PAPBaseTextCellDelegate
    
    /* Inform delegate that a user image or name was tapped */
    @IBAction func didTapUserButtonAction(sender: UIButton) {
        if(self.delegate != nil) {
            self.delegate!.cell?(self, didTapUserButton: self.user)
        }
    }
}
