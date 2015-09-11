//
//  PAPWelcomeViewController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 8/26/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse
import ParseUI
import FBSDKCoreKit


class PAPWelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PFUser.logOut()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {

            // If not logged in, present login view controller
            if(PFUser.currentUser() == nil) {
                self.performSegueWithIdentifier("showLoginViewController", sender: self)
                return
            }
            
            // Present Anypic UI
            self.performSegueWithIdentifier("showTabBarController", sender: self)
            
            // Present Anypic UI
            //appDelegate.presentTabBarController()
            
            // Refresh current user with server side data -- checks if user is still valid and so on
            PFUser.currentUser()!.fetchInBackgroundWithTarget(self, selector: "refreshCurrentUserCallbackWithResult:error:")
        }
        
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "showLoginViewController" {
            if let loginViewController = segue.destinationViewController as? PAPLogInViewController {
                loginViewController.fields = PFLogInFields.Facebook
                loginViewController.facebookPermissions = ["public_profile", "email", "user_friends"]
                
                if let appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate {
                    loginViewController.delegate = appDelegate
                }
            }
        }
        
        if segue.identifier == "showTabBarController" {
            print("sss")
        }
        
    }

    // MARK: - ()
    
    func refreshCurrentUserCallbackWithResult(refreshedObject: PFObject?, error: NSError?) {
        // A kPFErrorObjectNotFound error on currentUser refresh singals a deleted user
        if(error != nil && error!.code == PFErrorCode.ErrorObjectNotFound.rawValue) {
            println("User does not exist.")
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            //appDelegate.logOut()
            return
        }
        
        FBSDKAccessToken.refreshCurrentAccessToken { (connection, data, error) -> Void in
            // Check if user is missing a Facebook ID
            if(PAPUtility.userHasValidFacebookData(PFUser.currentUser()!)) {
                // User has Facebook ID.
                
                // refresh Facebook friends on each launch
            } else {
                
            }
        }
    }

}
