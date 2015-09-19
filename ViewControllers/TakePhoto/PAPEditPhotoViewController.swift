//
//  PAPEditPhotoViewController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 9/14/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse

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
    
    convenience init(image: UIImage) {
        self.init(nibName: "PAPEditPhotoViewController", bundle: nil)
        
        self.image = image
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
        //self.commentTextField = footerView.commentField;
        //self.commentTextField.delegate = self;
        
        // Set scroll view content size
        self.scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "BackgroundLeather.png")!)
        self.scrollView.contentSize = CGSizeMake(self.scrollView.bounds.size.width, self.photoImageView.frame.origin.y + self.photoImageView.frame.size.height + footerView.frame.size.height)
        
        // Notification
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide", name: UIKeyboardWillHideNotification, object: nil)
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
    
    
}
