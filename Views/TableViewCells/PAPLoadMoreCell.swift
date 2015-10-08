//
//  PAPLoadMoreCell.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 9/29/15.
//  Copyright © 2015 Xiao Jiang. All rights reserved.
//

import ParseUI

class PAPLoadMoreCell: PFTableViewCell {

    //
    var mainView: UIView!
    //
    var separatorImageTop: UIImageView!
    // 
    var separatorImageBottom: UIImageView!
    //
    var loadMoreImageView: UIImageView!
    //
    var hideSeparatorTop: Bool
    //
    var hideSeparatorBottom: Bool
    //
    var cellInsetWidth: CGFloat
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        mainView = nil
        separatorImageTop = nil
        separatorImageBottom = nil
        loadMoreImageView = nil
        hideSeparatorBottom = false
        hideSeparatorTop = false
        cellInsetWidth = 0
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
