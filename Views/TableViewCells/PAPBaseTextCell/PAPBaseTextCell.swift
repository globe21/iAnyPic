//
//  PAPBaseTextCell.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 10/8/15.
//  Copyright © 2015 Xiao Jiang. All rights reserved.
//

import UIKit

class PAPBaseTextCell: UITableViewCell {

    // MARK: - NSObject
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
