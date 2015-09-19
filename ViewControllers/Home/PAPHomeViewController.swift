//
//  PAPHomeViewController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 9/7/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit

class PAPHomeViewController: PAPPhotoTimelineViewController {

    var fistLaunch: Bool = false
    var blankTimelineView: UIView!
    //var settingsActionSheetDelegate: PAPSettingsActionSheetDelegate!

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "LogoNavigationBar.png"))
        
        //self.navigationItem.rightBarButtonItem = PAPSettingsButtonItem(target: self, action: "settingsButtonAction:")
        
        self.blankTimelineView = UIView(frame: self.tableView.bounds)
        
        let button = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        button.frame = CGRectMake(33.0, 96.0, 253.0, 173.0)
        button.setBackgroundImage(UIImage(named: "HomeTimelineBlank.png"), forState: UIControlState.Normal)
        button.addTarget(self, action: "inviteFriendsButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.blankTimelineView.addSubview(button)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - PFQueryTableViewController
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        // To-DO: && or &
        if(self.objects!.count == 0 && !self.queryForTable().hasCachedResult() && !self.fistLaunch) {
            self.tableView.scrollEnabled = false
            
            if(self.blankTimelineView.superview == nil) {
                self.blankTimelineView.alpha = 0.0
                self.tableView.tableHeaderView = self.blankTimelineView
                
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    self.blankTimelineView.alpha = 1.0
                })
            }
        } else {
            self.tableView.tableHeaderView = nil
            self.tableView.scrollEnabled = true
        }
    }
    
    // MARK: - ()
    
    func settingsButtonAction(sender: AnyObject) {
        
    }
    
    func inviteFriendsButtonAction(sender: AnyObject) {
        
    }
    
}
