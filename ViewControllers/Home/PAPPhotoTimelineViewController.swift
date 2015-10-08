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
    
    let CellIdentifier = "Cell"
    //
    let LoadMoreCellIdentifier = "LoadMoreCell"
    
    var shouldReloadOnAppear: Bool = true
    //
    var reusableSectionHeaderViews : Set<PAPPhotoHeaderView>!
    //
    var outstandingSectionHeaderQueries : [Int: Int]!
    
    // MARK: - Initialization
    
    required init!(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupController()
    }
    
    override init(style: UITableViewStyle, className: String?) {
        super.init(style: style, className: className)
        setupController()
    }
    
    func setupController() {
        
        reusableSectionHeaderViews = Set<PAPPhotoHeaderView>()

        outstandingSectionHeaderQueries = [Int: Int]()
        
        // The className to query on
        parseClassName = kPAPPhotoClassKey;
        
        // Whether the built-in pull-to-refresh is enabled
        pullToRefreshEnabled = true;
        
        // Whether the built-in pagination is enabled
        paginationEnabled = true;
        
        // The number of objects to show per page
        objectsPerPage = 10;
        
        // Improve scrolling performance by reusing UITableView section headers
        reusableSectionHeaderViews = Set<PAPPhotoHeaderView>()
        
        shouldReloadOnAppear = false;
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let texturedBackgroundView = UIView(frame: self.view.bounds)
        texturedBackgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundLeather.png")!)
        self.tableView.backgroundView = texturedBackgroundView
        
        self.registerNotification()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if self.shouldReloadOnAppear {
            self.shouldReloadOnAppear = false
            self.loadObjects()
        }
    }
    
    func registerNotification() {
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
            // Load more sections
            return nil
        }
        
        var headerView = self.dequeueReusableSectionHeaderView()
        if headerView == nil {
            headerView = PAPPhotoHeaderView(frame: CGRectMake(0.0, 0.0, self.view.bounds.size.width, 44.0), buttons: [PAPPhotoHeaderButtons.Like, PAPPhotoHeaderButtons.Comment, PAPPhotoHeaderButtons.User])
            headerView?.delegate = self
            self.reusableSectionHeaderViews.insert(headerView!)
        }
        
        let photo = self.objects?[section] as? PFObject
        headerView?.photo = photo
        headerView?.tag = section
        headerView?.likeButton.tag = section
        
        let attributesForPhoto = PAPCache.sharedCache().attributesForPhoto(photo)
        
        if(attributesForPhoto != nil) {
            headerView?.setLikeStatus(PAPCache.sharedCache().isPhotoLikedByCurrentUser(photo))
            headerView?.likeButton.setTitle(PAPCache.sharedCache().likeCountForPhoto(photo).description, forState: UIControlState.Normal)
            headerView?.commentButton.setTitle(PAPCache.sharedCache().commentCountForPhoto(photo).description, forState: UIControlState.Normal)
            
            if(headerView?.likeButton.alpha < 1.0 || headerView?.commentButton.alpha < 1.0) {
                UIView.animateWithDuration(0.2, animations: { () -> Void in
                    headerView?.likeButton.alpha = 1.0
                    headerView?.commentButton.alpha = 1.0
                })
            }
            
        } else {
            
            headerView?.likeButton.alpha = 0.0
            headerView?.commentButton.alpha = 0.0
            
            let lockQueue = dispatch_queue_create("com.iAnyPic.LockQueue", nil)
            dispatch_sync(lockQueue) {
                
                let outstandingSectionHeaderQueryStatus = self.outstandingSectionHeaderQueries[section]
                if(outstandingSectionHeaderQueryStatus == nil) {
                    let query = PAPUtility.queryForActivitiesOnPhoto(photo, cachePolicy: PFCachePolicy.NetworkOnly)
                    query.findObjectsInBackgroundWithBlock({ (objects, error) -> Void in
                        let lockQueue2 = dispatch_queue_create("com.iAnyPic.LockQueue2", nil)
                        dispatch_sync(lockQueue2) {
                            self.outstandingSectionHeaderQueries.removeValueForKey(section)
                            
                            if(error != nil) {
                                return
                            }
                            
                            var likers = [PFUser]()
                            var commenters = [PFUser]()
                            
                            var isLikedByCurrentUser = false
                            
                            for object in objects! {
                                if let activity = object as? PFObject {
                                    if(activity.objectForKey(kPAPActivityTypeKey)!.isEqualToString(kPAPActivityTypeLike)  && activity.objectForKey(kPAPActivityFromUserKey) != nil) {
                                        let user = activity.objectForKey(kPAPActivityFromUserKey) as! PFUser
                                        likers.append(user)
                                    } else if (activity.objectForKey(kPAPActivityTypeKey)!.isEqualToString(kPAPActivityTypeComment) && activity.objectForKey(kPAPActivityFromUserKey) != nil) {
                                        let commenter = activity.objectForKey(kPAPActivityFromUserKey) as! PFUser
                                        commenters.append(commenter)
                                    }
                                    
                                    let user = activity.objectForKey(kPAPActivityFromUserKey) as! PFUser
                                    if(user.objectId! == PFUser.currentUser()!.objectId!) {
                                        if(activity.objectForKey(kPAPActivityTypeKey)!.isEqualToString(kPAPActivityTypeLike)) {
                                            isLikedByCurrentUser = true
                                        }
                                    }
                                }
                            }
                            
                            PAPCache.sharedCache().setAttributesForPhoto(photo, likers: likers, commenters: commenters, likedByCurrentUser: isLikedByCurrentUser)
                            
                            if (headerView?.tag != section) {
                                return;
                            }
                            
                            headerView?.setLikeStatus(PAPCache.sharedCache().isPhotoLikedByCurrentUser(photo))
                            headerView?.likeButton.setTitle(PAPCache.sharedCache().likeCountForPhoto(photo).description, forState: UIControlState.Normal)
                            
                            headerView?.commentButton.setTitle(PAPCache.sharedCache().commentCountForPhoto(photo).description, forState:UIControlState.Normal)
                            
                            if (headerView?.likeButton.alpha < 1.0 || headerView?.commentButton.alpha < 1.0) {
                                UIView.animateWithDuration(0.2, animations: { () -> Void in
                                    headerView?.likeButton.alpha = 1.0
                                    headerView?.commentButton.alpha = 1.0
                                })
                            }

                        }
                    })
                }
            }

        }
        
        return headerView
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
            let query = PFQuery(className: self.parseClassName!)
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
        
        if(indexPath.section == self.objects?.count) {
            // this behavior is normally handled by PFQueryTableViewController, but we are using sections for each object and we must handle this ourselves
            return self.tableView(tableView, cellForNextPageAtIndexPath: indexPath)
        } else {
            var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? PAPPhotoCell
            
            if(cell == nil) {
                cell = PAPPhotoCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifier)
                cell!.photoButton.addTarget(self, action: "didTapOnPhotoAction:", forControlEvents: UIControlEvents.TouchUpInside)
            }
            
            cell!.photoButton.tag = indexPath.section
            cell!.imageView?.image = UIImage(named: "PlaceholderPhoto")
            cell!.imageView?.file = object?.objectForKey(kPAPPhotoPictureKey) as? PFFile
            
            // PFQTVC will take care of asynchronously downloading files, but will only load them when the tableview is not moving. If the data is there, let's load it right away.
            if(cell!.imageView!.file!.isDataAvailable) {
                cell?.imageView?.loadInBackground()
            }
            
            return cell
        }
    }
    
//    override func tableView(tableView: UITableView, cellForNextPageAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell? {
//        var cell = tableView.dequeueReusableCellWithIdentifier(LoadMoreCellIdentifier) as? PAPLoadMoreCell
//        if(cell == nil) {
//            cell = PAPLoadMoreCell.init(style: UITableViewCellStyle.Default, reuseIdentifier: LoadMoreCellIdentifier)
//            cell!.selectionStyle = UITableViewCellSelectionStyle.Gray
//            cell!.separatorImageTop.image = UIImage(named: "SeparatorTimelineDark")
//            cell!.hideSeparatorBottom = true
//            cell!.mainView.backgroundColor = UIColor.clearColor()
//        }
//        
//        return cell
//    }
    
    // MARK: - PAPPhotoTimelineViewController
    
    func dequeueReusableSectionHeaderView() -> PAPPhotoHeaderView? {
        for sectionHeaderView in self.reusableSectionHeaderViews {
            if sectionHeaderView.superview == nil {
                // we found a section header that is no longer visible
                return sectionHeaderView
            }
        }
        
        return nil
    }
    
    // MARK: - PAPPhotoHeaderViewDelegate
    
    func photoHeaderView(photoHeaderView: PAPPhotoHeaderView, didTapCommentOnPhotoButton button: UIButton, photo: PFObject) {
                let photoDetailsVC = PAPPhotoDetailsViewController(photo: photo)
                self.navigationController?.pushViewController(photoDetailsVC, animated: true)
    }
    
    func photoHeaderView(photoHeaderView: PAPPhotoHeaderView, didTapUserButton button: UIButton, user: PFUser) {
        let accountViewController = PAPAccountViewController(style: UITableViewStyle.Plain, className: kPAPPhotoClassKey)
        accountViewController.user = user
        self.navigationController?.pushViewController(accountViewController, animated: true)
    }
    
    func photoHeaderView(photoHeaderView: PAPPhotoHeaderView, didTapLikePhotoButton button: UIButton, photo: PFObject) {
        print("User did tap like button", terminator: "")
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
        print("User following changed.", terminator: "")
        self.shouldReloadOnAppear = true
    }
    
    func didTapOnPhotoAction(sender: UIButton) {
        if let photo = self.objects?[sender.tag] as? PFObject {
            if let navigationController = self.navigationController {
                let photoDetailsVC = PAPPhotoDetailsViewController(photo: photo)
                navigationController.pushViewController(photoDetailsVC, animated: true)
            }
            
        }
    }
}
