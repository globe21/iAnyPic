//
//  PAPPhotoTimelineViewController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 8/30/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class PAPPhotoTimelineViewController: PFQueryTableViewController, PAPPhotoHeaderViewDelegate {
    
    var shouldReloadOnAppear: Bool = true
    var reusableSectionHeaderViews : Set<PAPPhotoHeaderView>!
    var outstandingSectionHeaderQueries : [Int: Int]!
    
    // MARK: - Initialization
    
    required init!(coder aDecoder: NSCoder!) {
        super.init(coder: aDecoder)
    }
    
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        
        self.outstandingSectionHeaderQueries = [Int: Int]()
        
        // The className to query on
        self.parseClassName = className;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = true;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = true;
        
        // The number of objects to show per page
        self.objectsPerPage = 10;
        
        // Improve scrolling performance by reusing UITableView section headers
        self.reusableSectionHeaderViews = Set<PAPPhotoHeaderView>()
        
        self.shouldReloadOnAppear = false;
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - UIViewController
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if self.shouldReloadOnAppear {
            self.shouldReloadOnAppear = false
            self.loadObjects()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //        UIView *texturedBackgroundView = [[UIView alloc] initWithFrame:self.view.bounds];
        //        texturedBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BackgroundLeather.png"]];
        //        self.tableView.backgroundView = texturedBackgroundView;
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "userDidPublishPhoto:", name: PAPTabBarControllerDidFinishEditingPhotoNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"userFollowingChanged:", name:PAPUtilityUserFollowingChangedNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"userDidDeletePhoto", name:PAPPhotoDetailsViewControllerUserDeletedPhotoNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"userDidLikeOrUnlikePhoto", name:PAPPhotoDetailsViewControllerUserLikedUnlikedPhotoNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"userDidLikeOrUnlikePhoto", name:PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification, object:nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector:"userDidCommentOnPhoto", name:PAPPhotoDetailsViewControllerUserCommentedOnPhotoNotification, object:nil)
    }


    // MARK: - UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let objects = self.objects {
            var sections = objects.count
            if (self.paginationEnabled && sections != 0) {
                sections++
            }
            return sections
        }
        
        return 0
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    // MAKR: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == self.objects?.count {
            return nil
        }
        
        let headerView = self.dequeueReusableSectionHeaderView()
        if headerView == nil {
            //headerView = PAPPhotoHeaderView(frame: <#CGRect#>, buttons: <#PAPPhotoHeaderButtons#>)
        }
        
        //let photo = self.objects.
        
        //To-Do: not finished
        
        return nil
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == self.objects?.count) {
            return 0.0
        }
        
        return 44.0
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        // To-Do: How to load footer view from storyboard
        let footerView = UIView(frame: CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, 16.0))
        return footerView
    }
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(section == self.objects?.count) {
            return 0.0
        }
        
        return 16.0
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section >= self.objects?.count) {
            return 44.0
        }
        
        return 280.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if(indexPath.section == self.objects?.count && self.paginationEnabled) {
            // Load more cell
            self.loadNextPage()
        }
    }
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        if PFUser.currentUser() == nil {
            var query = PFQuery(className: self.parseClassName!)
            query.limit = 0
            return query
        }
        
        // Query for the friends the current user is following
        let followingActivitiesQuery = PFQuery(className: kPAPActivityClassKey)
        followingActivitiesQuery.whereKey(kPAPActivityTypeKey, equalTo: kPAPActivityTypeFollow)
        followingActivitiesQuery.whereKey(kPAPActivityFromUserKey, equalTo: PFUser.currentUser()!)
        
        // Using the activities from the query above, we find all of the photos taken by
        // the friends the current user is following
        let photosFromFollowedUsersQuery = PFQuery(className: self.parseClassName!)
        photosFromFollowedUsersQuery.whereKey(kPAPPhotoUserKey, matchesKey:kPAPActivityToUserKey, inQuery: followingActivitiesQuery)
        photosFromFollowedUsersQuery.whereKeyExists(kPAPPhotoPictureKey)
        
        // We create a second query for the current user's photos
        let photosFromCurrentUserQuery = PFQuery(className: self.parseClassName!)
        photosFromFollowedUsersQuery.whereKey(kPAPPhotoUserKey, equalTo: PFUser.currentUser()!)
        photosFromFollowedUsersQuery.whereKeyExists(kPAPPhotoPictureKey)
        
        // We create a final compound query that will find all of the photos that were
        // taken by the user's friends or by the user
        let query = PFQuery.orQueryWithSubqueries([photosFromFollowedUsersQuery, photosFromCurrentUserQuery])
        query.includeKey(kPAPPhotoUserKey)
        query.orderByDescending("createdAt")
        
        // A pull-to-refresh should always trigger a network request
        query.cachePolicy = PFCachePolicy.NetworkOnly
        
        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        // If there is no network connection, we will hit the cache first.
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
            if(self.objects!.count == 0 || !appDelegate.isParseReachable()) {
                query.cachePolicy = PFCachePolicy.CacheThenNetwork
            }
        }
                
        return query
    }
    
    override func objectAtIndexPath(indexPath: NSIndexPath?) -> PFObject? {
        // Overridden, since we want to implement sections
        if(indexPath?.section < self.objects?.count) {
            return self.objects![indexPath!.section] as? PFObject
        }
        
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
    
        return nil
    }
    
    override func tableView(tableView: UITableView, cellForNextPageAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell? {
        return nil
    }
    
    // MARK: - PAPPhotoTimelineViewController
    
    func dequeueReusableSectionHeaderView() -> PAPPhotoHeaderView? {
        for sectionHeaderView in self.reusableSectionHeaderViews {
            if sectionHeaderView.superview == nil {
                return sectionHeaderView
            }
        }
        
        return nil
    }
    
    // MARK: - PAPPhotoHeaderViewDelegate
    
    func photoHeaderView(photoHeaderView: PAPPhotoHeaderView, didTapCommentOnPhotoButton button: UIButton, photo: PFObject) {
        //        let photoDetailsVC = PAPPhotoDetailsViewController(photo: photo)
        //        self.navigationController?.pushViewController(photoDetailsVC, animated: true)
    }
    
    func photoHeaderView(photoHeaderView: PAPPhotoHeaderView, didTapUserButton button: UIButton, user: PFUser) {
        // To-Do: Perform segue ??
//        let accountViewController = PAPAccountViewController(UITableViewStyle.Plain)
//        accountViewController.user = user
//        self.navigationController?.pushViewController(accountViewController, animated: true)
    }
    
    func photoHeaderView(photoHeaderView: PAPPhotoHeaderView, didTapLikePhotoButton button: UIButton, photo: PFObject) {
        print("User did tap like button")
    }

    
    // MARK: - () 
    
    func indexPathForObject(targetObject: PFObject) -> NSIndexPath?{
        if let objects = self.objects {
            for var i = 0; i < objects.count; i++ {
                if let object = objects[i] as? PFObject {
                    if(object.objectId == targetObject.objectId) {
                        return NSIndexPath(forRow: 0, inSection: i)
                    }
                }
            }
        }
        
        return nil
    }
    
    func userDidLikeOrUnlikePhoto(notification: NSNotification) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func userDidCommentOnPhoto(notification: NSNotification) {
        self.tableView.beginUpdates()
        self.tableView.endUpdates()
    }
    
    func userDidDeletePhoto(notification: NSNotification) {
        // refresh timeline after a delay
        NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: "loadObjects", userInfo: nil, repeats: false)
    }
    
    func userDidPublishPhoto(notification: NSNotification) {
        if self.objects?.count > 0 {
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: true)
        }
        
        self.loadObjects()
    }
    
    func userFlollowingChanged(notificaion: NSNotification) {
        print("User following changed.")
        self.shouldReloadOnAppear = true
    }
    
    func didTapOnPhotoAction(sender: UIButton) {
        if let photo = self.objects?[sender.tag] as? PFObject {
            // To-Do: Perform with segue??
//            if let navigationController = self.navigationController {
//                let photoDetailsVC = PAPPhotoDetailsViewController(photo: photo)
//                navigationController.pushViewController(photoDetailsVC, animated: true)
//            }
            
        }
    }
}
