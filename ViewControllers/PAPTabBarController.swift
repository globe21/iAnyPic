//
//  PAPTabBarController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 8/26/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import MobileCoreServices

class PAPTabBarController: UITabBarController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Add camera button to tab bar
        var cameraButton = UIButton.buttonWithType(UIButtonType.Custom) as! UIButton
        let cameraButtonWidth = CGFloat(130.0)
        cameraButton.frame = CGRectMake((self.tabBar.bounds.width - cameraButtonWidth)/2.0, 0.0, cameraButtonWidth, self.tabBar.bounds.height)
        cameraButton.setImage(UIImage(named: "ButtonCamera.png"), forState: UIControlState.Normal)
        cameraButton.setImage(UIImage(named: "ButtonCameraSelected.png"), forState: UIControlState.Highlighted)
        cameraButton.addTarget(self, action: "photoCaptureButtonAction:", forControlEvents: UIControlEvents.TouchUpInside)
        self.tabBar.addSubview(cameraButton)
        
        // Add swipe gesture to the camera button
        var swipeUpGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "handleGesture:")
        swipeUpGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Up
        swipeUpGestureRecognizer.numberOfTouchesRequired = 1
        cameraButton.addGestureRecognizer(swipeUpGestureRecognizer)

        //[PAPUtility addBottomDropShadowToNavigationBarForNavigationController:];
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - UITabBarController
    
    override func setViewControllers(viewControllers: [AnyObject], animated: Bool) {
        super.setViewControllers(viewControllers, animated: animated)
        
    }
    
    // MARK: - UIActionSheetDelegate
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        if(buttonIndex == 0) {
            self.shouldStartCameraController()
        } else if (buttonIndex == 1) {
            self.shouldStartPhotoLibraryPickerController()
        }
    }

    
    // MARK: - UIImagePickerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.dismissViewControllerAnimated(false, completion: nil)
        
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
//            var editPhotoViewController = PAPEditPhotoViewController(anImage: image)
//            editPhotoViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
//            
//            self.navController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
//            self.navController.pushViewController(editPhotoViewController, animated: false)
//            self.presentViewController(self.navController, animated: true, completion: nil)
        }
    }
    
    
    // MARK: - PAPTabBarController
    
    func shouldPresentPhotoCaptureController() -> Bool {
        var presentedPhotoCaptureController = self.shouldStartCameraController()
        
        if(!presentedPhotoCaptureController) {
            presentedPhotoCaptureController = self.shouldStartPhotoLibraryPickerController()
        }
        
        return presentedPhotoCaptureController
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    
    // MARK: - ()
    
    func handleGesture(gestureRecognizer: UIGestureRecognizer) {
        self.shouldPresentPhotoCaptureController()
    }
    
    func photoCaptureButtonAction(sender: AnyObject) {
        var cameraDeviceAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        var photoLibraryAvailable = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)
        
        if(cameraDeviceAvailable && photoLibraryAvailable) {
            var actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil, otherButtonTitles: "Take Photo", "Choose Photo")
            actionSheet.showFromTabBar(self.tabBar)
        } else  {
            // If we don't have at least two options, we automatically show whichever is available (camera or roll)
            self.shouldPresentPhotoCaptureController()
        }
    }
    
    func shouldStartCameraController() -> Bool {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) == false) {
            return false
        }
        
        var cameraUI = UIImagePickerController()
        
        cameraUI.mediaTypes = [kUTTypeImage as! String]
        cameraUI.sourceType = UIImagePickerControllerSourceType.Camera
        
        if(UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Rear)) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.Rear
        } else if(UIImagePickerController.isCameraDeviceAvailable(UIImagePickerControllerCameraDevice.Front)) {
            cameraUI.cameraDevice = UIImagePickerControllerCameraDevice.Front
        }
        
        cameraUI.allowsEditing = true
        cameraUI.showsCameraControls = true
        cameraUI.delegate = self
        self.presentViewController(cameraUI, animated: true, completion: nil)
        
        return true
    }
    
    func shouldStartPhotoLibraryPickerController() -> Bool {
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary) == false && UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) == false) {
            return false
        }
        
        var cameraUI = UIImagePickerController()
        var mediaTypes = UIImagePickerController.availableMediaTypesForSourceType(UIImagePickerControllerSourceType.PhotoLibrary)
        // To-Do: contains?
        
        if(UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.PhotoLibrary)) {
            
            cameraUI.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            cameraUI.mediaTypes = [kUTTypeImage as! String]
            
        } else if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) ) {
            
            cameraUI.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            cameraUI.mediaTypes = [kUTTypeImage as! String]
            
        } else {
            return false
        }
        
        cameraUI.allowsEditing = true
        cameraUI.delegate = self
        
        self.presentViewController(cameraUI, animated: true, completion: nil)
        
        return true
    }
}


protocol PAPTabBarControllerDelegate {
    
    func tabBarController(tabBarController: UITabBarController, cameraButtonTouchUpInsideAction button: UIButton)
    
}

