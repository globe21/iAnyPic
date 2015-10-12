//
//  PAPPhotoDetailsViewController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 10/7/15.
//  Copyright © 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import MBProgressHUD

class PAPPhotoDetailsViewController: PFQueryTableViewController, UITextFieldDelegate, UIActionSheetDelegate, PAPPhotoDetailsHeaderViewDelegate {
    
    var photo: PFObject!
    
    var commentTextField: UITextField!
    
    var headerView: PAPPhotoDetailsHeaderView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupController()
    }

    init(photo: PFObject) {
        super.init(style: UITableViewStyle.Plain, className: kPAPActivityClassKey)
        
        setupController()
        
        self.photo = photo
    }
    
    func setupController() {
        self.parseClassName = kPAPActivityClassKey
        self.objectsPerPage = 10
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.tableView.showsVerticalScrollIndicator = false
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "LogoNavigationBar"))
        self.navigationItem.hidesBackButton = true
        
        // Add back button to navigation bar
        let backButton = UIButton(type: UIButtonType.Custom)
        backButton.frame = CGRectMake(0, 0, 52.0, 32)
        backButton.setTitle("Back", forState: UIControlState.Normal)
        backButton.setTitleColor(UIColor(red: 214.0/255.0, green: 210.0/255.0, blue: 197.0/255.0, alpha: 1.0), forState: UIControlState.Normal)
        backButton.titleLabel?.font = UIFont.boldSystemFontOfSize(UIFont.smallSystemFontSize())
        backButton.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: 5.0, bottom: 0.0, right: 0.0)
        backButton.addTarget(self, action: "backButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        backButton.setBackgroundImage(UIImage(named: "ButtonBack.png"), forState: UIControlState.Normal)
        backButton.setBackgroundImage(UIImage(named: "ButtonBackSelected.png"), forState: UIControlState.Highlighted)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        // Set table view properties
        let textureBackgroundView = UIView(frame: self.view.bounds)
        textureBackgroundView.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundLeather.png")!)
        self.tableView.backgroundView = textureBackgroundView
        
        // Set table header
        self.headerView = PAPPhotoDetailsHeaderView(frame: PAPPhotoDetailsHeaderView.rectForView(), photo: self.photo)
        self.headerView.delegate = self
        self.tableView.tableHeaderView = self.headerView
        
        
        // Set table footer
        let footerView = PAPPhotoDetailsFooterView(frame: PAPPhotoDetailsFooterView.rectForView())
        commentTextField = footerView.commentField
        commentTextField.delegate = self
        self.tableView.tableFooterView = footerView
        
        let photoOwner = self.photo[kPAPPhotoUserKey] as! PFUser
        if(photoOwner.objectId == PFUser.currentUser()?.objectId) {
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "actionButtonAction:")
        }
        
        // Register to be notified when the keyboard will be shown to scroll the view
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: PAPUtilityUserLikedUnlikedPhotoCallbackFinishedNotification, object: self.photo)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.headerView.reloadLikeBar()
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.row < self.objects?.count) { // A comment row
            //let object = self.objects![indexPath.row]
            //let fromUser = object[kPAPActivityFromUserKey] as! PFUser
            
            //let commentString = object[kPAPActivityContentKey] as? String
            //let nameString = fromUser[kPAPUserDisplayNameKey] as? String
            
//            return [PAPActivityCell heightForCellWithName:nameString contentString:commentString cellInsetWidth:kPAPCellInsetWidth];
            return 56.0
        } else {
            // Paging row
            return 44.0
        }
    }
    
    
    // MARK: - PFQueryTableViewController
    
    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: self.parseClassName!)
        query.whereKey(kPAPActivityPhotoKey, equalTo: self.photo)
        query.includeKey(kPAPActivityFromUserKey)
        query.whereKey(kPAPActivityTypeKey, equalTo: kPAPActivityTypeComment)
        query.orderByAscending("createdAt")
        
        query.cachePolicy = PFCachePolicy.NetworkOnly
        
        // If no objects are loaded in memory, we look to the cache first to fill the table
        // and then subsequently do a query against the network.
        
        // If there is no network connection, we will hit the cache first.
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        if(self.objects?.count == 0 || appDelegate.isParseReachable()) {
            query.cachePolicy = PFCachePolicy.CacheThenNetwork
        }
        
        return query;
    }
    
    override func objectsDidLoad(error: NSError?) {
        super.objectsDidLoad(error)
        
        print("PAPPhotoDetailsViewController: Objects did load")
        self.headerView.reloadLikeBar()
    }
    
    
    // MARK: - UITableViewController
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let CellIdentifier = "CommentCell"
        
        // Try to deque a cell and create one if necessary
        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? PAPBaseTextCell
        if(cell == nil)
        {
            cell = PAPBaseTextCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifier)
        }
        
        cell!.user = object?.objectForKey(kPAPActivityFromUserKey) as? PFUser
        cell!.contentText = object?.objectForKey(kPAPActivityContentKey) as? String
        cell!.date = object?.createdAt
        
        return cell
    }
    
    override func tableView(tableView: UITableView, cellForNextPageAtIndexPath indexPath: NSIndexPath) -> PFTableViewCell? {
        let CellIdentifier = "PagingCell"
        let PAPCellInsetWidth: CGFloat = 20.0

        var cell = tableView.dequeueReusableCellWithIdentifier(CellIdentifier) as? PAPLoadMoreCell
        if(cell == nil)
        {
            cell = PAPLoadMoreCell(style: UITableViewCellStyle.Default, reuseIdentifier: CellIdentifier)
            cell?.cellInsetWidth = PAPCellInsetWidth
            cell?.hideSeparatorTop = true
        }
        
        return cell
    }


    // MARK: - UIScrollViewDelegate
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.commentTextField.resignFirstResponder()
    }
    
    // MARK: - PAPPhotoDetailsHeaderViewDelegate
    
    func photoDetailsHeaderView(headerView: PAPPhotoDetailsHeaderView, didTapUserButton button: UIButton, user: PFUser) {
        self.shouldPresentAccountViewForUser(user)
    }
    
    func actionButtonAction(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.Destructive, handler: nil))
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    // MARK: - ()
    
    func handleCommentTimeout(timer: NSTimer) {
        MBProgressHUD.hideHUDForView(self.view.superview, animated: true)
        
        let alertController = UIAlertController(title: "New Comment", message: "Your comment will be posted next time there is an internet connection.", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func shouldPresentAccountViewForUser(user: PFUser) {
        let accountViewController = PAPAccountViewController(style: UITableViewStyle.Plain)
        accountViewController.user = user
        self.navigationController?.pushViewController(accountViewController, animated: true)
    }
    
    func backButtonAction(sender: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func userLikedOrUnlikedPhoto(notification: NSNotification) {
        self.headerView.reloadLikeBar()
    }
    
    func keyboardWillShow(notification: NSNotification) {
        // Scroll the view to the comment text box
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue().size
        
        self.tableView.setContentOffset(CGPointMake(0, self.tableView.contentSize.height - keyboardSize.height), animated: true)
    }

}
