//
//  PAPAccountViewController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 10/6/15.
//  Copyright © 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PAPAccountViewController: PAPPhotoTimelineViewController {
    
    var user: PFUser!
    
    var headerView: UIView!
    
    // MARK: - UIViewController
    
    init(user: PFUser, style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        
        self.user = user
    }

    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "LogoNavigationBar.png"))
        
        // Add back button to navigation bar
        let backbutton = UIButton(type: UIButtonType.Custom)
        backbutton.frame = CGRectMake(0.0, 0.0, 52.0, 32.0)
        backbutton.setTitle("Back", forState: UIControlState.Normal)
        backbutton.setTitleColor(UIColor(red: 214.0/255.0, green: 210.0/255.0, blue: 197.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
        backbutton.titleLabel?.font = UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
        backbutton.titleEdgeInsets = UIEdgeInsetsMake(0.0, 5.0, 0.0, 0.0)
        backbutton.addTarget(self, action: "backButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        backbutton.setBackgroundImage(UIImage(named: "ButtonBack"), forState: UIControlState.Normal)
        backbutton.setBackgroundImage(UIImage(named: "ButtonBackSelected"), forState: UIControlState.Highlighted)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backbutton)
        
        // Create header view
        self.headerView = UIView(frame: CGRectMake(0.0, 0.0, self.tableView.bounds.width, 222.0))
        self.headerView.backgroundColor = UIColor.clearColor()

        // Set background image
        let texturedBackgroundView = UIView(frame: self.view.bounds)
        texturedBackgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundLeather.png")!)
        self.tableView.backgroundView = texturedBackgroundView
        
        // Create profile picture background view
        let profilePictureBackgroundView = UIView(frame: CGRectMake(94.0, 38.0, 132.0, 132.0))
        profilePictureBackgroundView.backgroundColor = UIColor.darkGrayColor()
        var layer = profilePictureBackgroundView.layer
        layer.cornerRadius = 10.0
        layer.masksToBounds = true
        self.headerView.addSubview(profilePictureBackgroundView)
        
        // Create profile picture view
        let profilePictureImageView = PFImageView(frame: CGRectMake(94.0, 38.0, 132.0, 132.0))
        profilePictureImageView.contentMode = UIViewContentMode.ScaleAspectFill
        layer = profilePictureImageView.layer
        layer.cornerRadius =  10.0
        layer.masksToBounds = true
        profilePictureImageView.alpha = 0.0
        self.headerView.addSubview(profilePictureImageView)

        // Create profile picture stroke image view
        let profilePictureStrokeImageView = UIImageView(frame : CGRectMake(88.0, 34.0, 143.0, 143.0))
        profilePictureStrokeImageView.alpha = 0.0
        profilePictureStrokeImageView.image = UIImage(named: "ProfilePictureStroke.png")
        self.headerView.addSubview(profilePictureStrokeImageView)
        
        // Set profile image
        if let imageFile = self.user.objectForKey(kPAPUserProfilePicMediumKey) as? PFFile {
            profilePictureImageView.file = imageFile
            profilePictureImageView.loadInBackground({ (image, error) -> Void in
                if(error == nil) {
                    UIView.animateWithDuration(0.2, animations: { () -> Void in
                        profilePictureBackgroundView.alpha = 1.0
                        profilePictureStrokeImageView.alpha = 1.0
                        profilePictureImageView.alpha = 1.0
                    })
                }
            })
        }
        
        // Create photo count icon
        let photoCountIconImageView = UIImageView(image: UIImage(named: "IconPics.png"))
        photoCountIconImageView.frame = CGRectMake(26.0, 50.0, 450, 37.0)
        self.headerView.addSubview(photoCountIconImageView)
        
        // Create photoCountLabel 
        let photoCountLabel = UILabel(frame: CGRectMake(0.0, 94.0, 92.0, 22.0))
        photoCountLabel.textAlignment = NSTextAlignment.Center
        photoCountLabel.backgroundColor = UIColor.clearColor()
        photoCountLabel.textColor = UIColor.whiteColor()
        photoCountLabel.shadowColor = UIColor(white: 0.0, alpha: 0.3)
        photoCountLabel.shadowOffset = CGSizeMake(0.0, -1.0)
        photoCountLabel.font = UIFont.boldSystemFontOfSize(14.0)
        self.headerView.addSubview(photoCountLabel)
        
        // Create followers icon
        let followersIconImageView = UIImageView(image: UIImage(named: "IconFollowers.png"))
        followersIconImageView.frame = CGRectMake( 247.0, 50.0, 52.0, 37.0)
        self.headerView.addSubview(followersIconImageView)
        
        // Create follower count label
        let followerCountLabel = UILabel(frame: CGRectMake(226.0, 94.0, self.headerView.bounds.size.width - 226.0, 16.0))
        followerCountLabel.textAlignment = NSTextAlignment.Center
        followerCountLabel.backgroundColor = UIColor.clearColor()
        followerCountLabel.textColor = UIColor.whiteColor()
        followerCountLabel.font = UIFont.boldSystemFontOfSize(12.0)
        self.headerView.addSubview(followerCountLabel)
        
        // Create following count label
        let followingCountLabel = UILabel(frame: CGRectMake(226.0, 110.0, self.headerView.bounds.size.width - 226.0, 16.0))
        followingCountLabel.textAlignment = NSTextAlignment.Center
        followingCountLabel.backgroundColor = UIColor.clearColor()
        followingCountLabel.textColor = UIColor.whiteColor()
        followingCountLabel.font = UIFont.boldSystemFontOfSize(12.0)
        self.headerView.addSubview(followingCountLabel)

        // Create user name label
        let userDisplayNameLabel = UILabel(frame: CGRectMake(0, 176.0, self.headerView.bounds.size.width, 22.0))
        userDisplayNameLabel.textAlignment = NSTextAlignment.Center
        userDisplayNameLabel.backgroundColor = UIColor.clearColor()
        userDisplayNameLabel.textColor = UIColor.whiteColor()
        userDisplayNameLabel.text = self.user.objectForKey("displayName") as? String
        userDisplayNameLabel.font = UIFont.boldSystemFontOfSize(18.0)
        self.headerView.addSubview(userDisplayNameLabel)
        
        // Get number of photos
        photoCountLabel.text = "0 photos"
        
        let queryPhotoCount = PFQuery(className: "Photo")
        queryPhotoCount.whereKey(kPAPPhotoUserKey, equalTo: self.user)
        queryPhotoCount.cachePolicy = PFCachePolicy.CacheThenNetwork
        queryPhotoCount.countObjectsInBackgroundWithBlock { (number, error) -> Void in
            if(error == nil) {
                photoCountLabel.text = String(format: "%d photo%@", number, number==1 ? "" : "s")
                PAPCache.sharedCache().setPhotoCount(NSNumber(int: number), user: self.user)
            }
        }
        
        // Get number of followers
        followerCountLabel.text = "0 followers"
        
        let queryFollowerCount = PFQuery(className: kPAPActivityClassKey)
        queryFollowerCount.whereKey(kPAPActivityTypeKey, equalTo: kPAPActivityTypeFollow)
        queryFollowerCount.whereKey(kPAPActivityToUserKey, equalTo: self.user)
        queryFollowerCount.cachePolicy = PFCachePolicy.CacheThenNetwork
        queryFollowerCount.countObjectsInBackgroundWithBlock { (number, error) -> Void in
            if(error == nil) {
                followerCountLabel.text = String(format: "%d follower%@", number, number==1 ? "" : "s")
            }
        }
        
        // Get number of following
        followingCountLabel.text = "0 following"
        
        if let followingDictionary = PFUser.currentUser()!.objectForKey("following") as? Dictionary<String, String> {
            followingCountLabel.text = String(format: "%d following", followingDictionary.count)
        }
        
        // Query for following count
        let queryFollowingCount = PFQuery(className: kPAPActivityClassKey)
        queryFollowingCount.whereKey(kPAPActivityTypeKey, equalTo: kPAPActivityTypeFollow)
        queryFollowingCount.whereKey(kPAPActivityFromUserKey, equalTo: self.user)
        queryFollowingCount.cachePolicy = PFCachePolicy.CacheThenNetwork
        queryFollowingCount.countObjectsInBackgroundWithBlock { (number, error) -> Void in
            if(error == nil) {
                followingCountLabel.text = String(format: "%d following", number)
            }
        }
        
        // 
        if(self.user.objectId == PFUser.currentUser()?.objectId) {
            let loadingActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
            loadingActivityIndicatorView.startAnimating()
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingActivityIndicatorView)
            
            // Check if the currentUser is following this user
            let queryIsFollowing = PFQuery(className: kPAPActivityClassKey)
            queryIsFollowing.whereKey(kPAPActivityTypeKey, equalTo: kPAPActivityTypeFollow)
            queryIsFollowing.whereKey(kPAPActivityToUserKey, equalTo: self.user)
            queryIsFollowing.whereKey(kPAPActivityFromUserKey, equalTo: PFUser.currentUser()!)
            queryIsFollowing.cachePolicy = PFCachePolicy.CacheThenNetwork
            queryIsFollowing.countObjectsInBackgroundWithBlock({ (number, error ) -> Void in
                if(error != nil) {
                    self.navigationItem.rightBarButtonItem = nil
                } else {
                    if(number == 0) {
                        self.configureFollowButton()
                    } else {
                        self.configureUnfollowButton()
                    }
                }
            })
        }
        
    }

    // MARK: - PFQueryTableViewController
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        self.tableView.tableHeaderView = self.headerView
    }
    
    override func queryForTable() -> PFQuery {
        if(self.user != nil) {
            let query = PFQuery(className: self.parseClassName!)
            query.limit = 0
            return query
        }
        
        let query = PFQuery(className: self.parseClassName!)
        query.cachePolicy = PFCachePolicy.NetworkOnly
        if(self.objects?.count == 0) {
            query.cachePolicy = PFCachePolicy.CacheThenNetwork
        }
        query.whereKey(kPAPPhotoUserKey, equalTo: self.user)
        query.orderByDescending("createdAt")
        query.includeKey(kPAPPhotoUserKey)
        
        return query
    }
    
    override func tableView(tableView: UITableView, cellForNextPageAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell? {
        let LoadMoreCellIdentifier = "LoadMoreCell"
        
        var cell = tableView.dequeueReusableCellWithIdentifier(LoadMoreCellIdentifier) as? PFTableViewCell
        if(cell == nil) {
            cell = PAPLoadMoreCell(style: UITableViewCellStyle.Default, reuseIdentifier: LoadMoreCellIdentifier)
            cell?.selectionStyle = UITableViewCellSelectionStyle.Gray
            //cell?.separatorImageTop.image = UIImage(name: "SeparatorTimelineDark.png")
            //cell.hideSeparatorBottom = true
            //cell.mainView.backgroundColor = UIColor.clearColor()
        }
        
        return cell
    }
    
    // MARK: - ()
    
    func followButtonAction(sender: UIButton) {
        let loadingActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loadingActivityIndicatorView.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingActivityIndicatorView)
        
        self.configureUnfollowButton()
        
        PAPUtility.followUserEventually(self.user) { (succeeded, error) -> Void in
            if(error != nil) {
                self.configureFollowButton()
            }
        }
    }
    
    func unfollowButtonAction(sender: UIButton) {
        let loadingActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.White)
        loadingActivityIndicatorView.startAnimating()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: loadingActivityIndicatorView)
        
        self.configureFollowButton()
        
        PAPUtility.unfollowUserEventually(self.user)
    }
    
    func backButtonAction(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func configureFollowButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: UIBarButtonItemStyle.Plain, target: self, action: "followButtonAction:")
        PAPCache.sharedCache().setFollowStatus(false, user: self.user)
    }
    
    func configureUnfollowButton() {
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Unfollow", style: UIBarButtonItemStyle.Plain, target: self, action: "unfollowButtonAction:")
        PAPCache.sharedCache().setFollowStatus(true, user: self.user)
        
    }
}
