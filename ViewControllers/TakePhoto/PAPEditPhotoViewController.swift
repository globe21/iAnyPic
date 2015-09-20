//
//  PAPEditPhotoViewController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 9/14/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse
import UIImageSwiftExtensions

class PAPEditPhotoViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var photoImageView: UIImageView!
    @IBOutlet var footerView: PAPPhotoDetailsFooterView!
    
    var commentTextField: UITextField!
    
    var photoFile: PFFile?
    var thumbnailFile: PFFile?
    var image: UIImage?
    
    var fileUploadBackgroundTaskId: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    var photoPostBackgroundTaskId: UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
    
    // MARK: - NSObject
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        if let view = NSBundle.mainBundle().loadNibNamed("PAPEditPhotoView", owner: self, options: nil)[0] as? UIView {
            self.view = view
        }
    }
    
    init(image: UIImage?) {

        self.image = image

        super.init(nibName: "PAPEditPhotoView", bundle: nil)        
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.photoImageView.image = self.image
        
        var layer = photoImageView.layer
        layer.masksToBounds = false
        layer.shadowRadius = 3.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
        layer.shadowOpacity = 0.5
        layer.shouldRasterize = true
        
        // Init navigation items
        self.navigationItem.hidesBackButton = true
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "LogoNavigationBar.png"))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Done, target: self, action: "cancelButtonAction:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Publish", style: UIBarButtonItemStyle.Done, target: self, action: "doneButtonAction:")
        
        // Setup text field
        self.commentTextField = footerView.commentField;
        self.commentTextField.delegate = self;
        
        // Set scroll view content size
        self.scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundLeather.png")!)
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.photoImageView.frame.origin.y + self.photoImageView.frame.size.height + footerView.frame.size.height)
        
        // Notification
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        //NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        self.shouldUploadImage(self.image!)
    }

    // MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        //self.doneButtonAction(textField)
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.commentTextField.resignFirstResponder()
    }
    
    
    // MARK: - ()
    
    func shouldUploadImage(anImage: UIImage) -> Bool {
        let resizedImage = anImage.resizedImageWithContentMode(UIViewContentMode.ScaleAspectFit, bounds: CGSizeMake(560.0, 560.0), interpolationQuality: kCGInterpolationHigh)
        let thumbnaimImage = anImage.thumbnailImage(86, transparentBorder: 0, cornerRadius: 10, interpolationQuality: kCGInterpolationDefault)
        
        // JPEG to decrease file size and enable faster uploads & downloads
        let imageData = UIImageJPEGRepresentation(resizedImage, 0.8)
        let thumnailImageData = UIImagePNGRepresentation(thumbnaimImage)
        
        self.photoFile = PFFile(data: imageData)
        self.thumbnailFile = PFFile(data: thumnailImageData)
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrouned
        self.fileUploadBackgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskId)
        })
        
        println("Requested background expiration task with id \(self.fileUploadBackgroundTaskId) for Anypic photo upload")
        
        self.photoFile?.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
            if(succeeded) {
                println("Photo uploaded successfully")
                self.thumbnailFile?.saveInBackgroundWithBlock({ (succeeded, error) -> Void in
                    if(succeeded) {
                        println("Thumbnail uploaded successfully.")
                    } else {
                        println(error)
                    }
                    UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskId)
                })
            } else {
                println(error)
                UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskId)
            }
        })
        
        return true
    }
    
    // MARK: - Keyboard Notification
    
    func keyboardWillShow(notification: NSNotification) {
        let info = notification.userInfo!
        let keyboardFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var scrollViewContentSize = self.scrollView.bounds.size
        scrollViewContentSize.height += keyboardFrame.size.height
        self.scrollView.contentSize = scrollViewContentSize
        
        var scrollViewContentOffset = self.scrollView.contentOffset
        scrollViewContentOffset.y += keyboardFrame.size.height
        scrollViewContentOffset.y -= 42.0
        self.scrollView.contentOffset = scrollViewContentOffset
    }
    
    func keyboardWillHide(notificaiton: NSNotification) {
        let info = notificaiton.userInfo!
        let keybaordFrame = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).CGRectValue()
        
        var scrollViewContentSize = self.scrollView.bounds.size
        scrollViewContentSize.height -= keybaordFrame.size.height
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            self.scrollView.contentSize = scrollViewContentSize
        })
    }
    
    // MAKR: - UIButton Actions
    
    func doneButtonAction(button: UIButton) {
        var userInfo = Dictionary<String, String>()
        var trimmedComment = self.commentTextField.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
        if(count(trimmedComment) != 0) {
            userInfo[kPAPEditPhotoViewControllerUserInfoCommentKey] = trimmedComment
        }
        
        if(self.photoFile == nil || self.thumbnailFile == nil) {
            UIAlertView(title: "Couldn't post your photo", message: nil, delegate: nil, cancelButtonTitle: nil).show()
            return
        }
        
        // both files have finished uploading
        
        // create a photo object
        var photo = PFObject(className: kPAPPhotoClassKey)
        photo.setObject(PFUser.currentUser()!, forKey: kPAPPhotoUserKey)
        photo.setObject(self.photoFile!, forKey: kPAPPhotoPictureKey)
        photo.setObject(self.thumbnailFile!, forKey: kPAPPhotoThumbnailKey)
        
        // photos are public, but may only be modified by the user who uploaded them
        var photoACL = PFACL(user: PFUser.currentUser()!)
        photoACL.setPublicReadAccess(true)
        photoACL.setPublicWriteAccess(false)
        photo.ACL = photoACL
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        self.photoPostBackgroundTaskId = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({ () -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskId)
        })
        
        // save
        photo.saveInBackgroundWithBlock { (succeeded, error) -> Void in
            if(succeeded) {
                println("Photo uploaded")
                PAPCache.sharedCache().setAttributesForPhoto(photo, likers: [], commenters: [], likedByCurrentUser: false)
                
                // userInfo might contain any caption which might have been posted by the uploader
                let commentText = userInfo[kPAPEditPhotoViewControllerUserInfoCommentKey]
                
                if(commentText != nil && count(commentText!) != 0) {
                    // create and save photo caption
                    var comment = PFObject(className: kPAPActivityClassKey)
                    comment.setObject(kPAPActivityTypeComment, forKey: kPAPActivityTypeKey)
                    comment.setObject(photo, forKey: kPAPActivityPhotoKey)
                    comment.setObject(PFUser.currentUser()!, forKey: kPAPActivityFromUserKey)
                    comment.setObject(PFUser.currentUser()!, forKey: kPAPActivityToUserKey)
                    comment.setObject(commentText!, forKey: kPAPActivityContentKey)
                    
                    var ACL = PFACL(user: PFUser.currentUser()!)
                    ACL.setPublicReadAccess(true)
                    comment.ACL = ACL
                    
                    comment.saveEventually()
                    PAPCache.sharedCache().incrementCommentCountForPhoto(photo)
                }
                
                NSNotificationCenter.defaultCenter().postNotificationName(PAPTabBarControllerDidFinishEditingPhotoNotification, object: photo)
                
            } else {
                println("Photo failed to save \(error)")
                UIAlertView(title: "Couldn't post your photo", message: nil, delegate: nil, cancelButtonTitle: "Dismiss").show()
            }
            
            UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskId)
        }
        
        self.navigationController?.popViewControllerAnimated(true)

    }
    
    func cancelButtonAction(button: UIButton) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    

}
