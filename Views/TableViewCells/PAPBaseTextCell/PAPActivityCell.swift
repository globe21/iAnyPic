//
//  PAPActivityCell.swift
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
@objc protocol PAPActivityCellDelegate: PAPBaseTextCellDelegate {
    
    /*!
    Sent to the delegate when the activity button is tapped
    @param activity the PFObject of the activity that was tapped
    */
    optional func cell(cellView: PAPActivityCell, didTapActivityButton activity: PFObject)
}


class PAPActivityCell: PAPBaseTextCell {

    /*! The activity associated with this cell */
    var activity: PFObject!

    var activityImageView: PAPProfileImageView!
    
    var activityImageButton: UIButton!
    
    /*! Flag to remove the right-hand side image if not necessary */
    var hasActivityImage: Bool = false
    
    // MARK: UIView
    
}
