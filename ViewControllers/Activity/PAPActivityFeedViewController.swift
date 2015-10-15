//
//  PAPActivityFeedViewController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 10/13/15.
//  Copyright © 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import ParseUI

class PAPActivityFeedViewController: PFQueryTableViewController {

    let kPAPActivityTypeLikeString = "liked your photo"
    let kPAPActivityTypeCommentString = "commented on your photo"
    let kPAPActivityTypeFollowString = "started following you"
    let kPAPActivityTypeJoinedString = "joined Anypic"

    //var settingsActionSheetDelegate: PAPSettingsActionSheetDelegate?
    var lastRefresh: NSDate?
    var blankTimelineView: UIView?

    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        initSetup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initSetup()
    }
    
    func initSetup() {
        // The className to query on
        self.parseClassName = kPAPActivityClassKey
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = true
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = true
        
        // The number of objects to show per page
        self.objectsPerPage = 15
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
