/*!
@header     AppDelegate.swift

@brief      The delegate of UIApplication

This file contains the most importnant method and properties decalaration.

@author     Jiang Xiao

@copyright  2015 Jiang Xiao. All rights reserved.

@version    15.12.7
*/

import UIKit
import Parse
import ParseUI
import Bolts
import FBSDKCoreKit
import ParseFacebookUtilsV4
import MBProgressHUD

@UIApplicationMain

class AppDelegate: UIResponder, UIApplicationDelegate,  PFLogInViewControllerDelegate{
    
    var networkStatus: NetworkStatus?

    var window: UIWindow?
    var rootNavController: UINavigationController!
    
    let applicationID = "3ZSqi4DihLegAwqnu3GVOpFccEFQ4UeIkOuk3UHc"
    let clientKey = "vgcqlEbtdsptzPSiH9cIsbbYPEdCpGeh61Rnf80F"

    // MARK: - UIApplicationDelegate
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // Enable local Datastore
        // Parse.enableLocalDatastore()

        // Parse Initialization
        Parse.setApplicationId(applicationID, clientKey: clientKey)
        
        // Make sure to update your URL scheme to match this facebook id.
        PFFacebookUtils.initializeFacebookWithApplicationLaunchOptions(launchOptions)
//
//        // Clear application icon badge number
//        if(application.applicationIconBadgeNumber != 0) {
//            application.applicationIconBadgeNumber = 0
//        }
//        
//        // Enable public read access by default, with any newly created PFObjects belonging to the current user
//        var defaultACL = PFACL()
//        defaultACL.setPublicReadAccess(true)
//        PFACL.setDefaultACL(defaultACL, withAccessForCurrentUser: true)
//        
//        // Set up our app's global UIAppearance
//        self.setupAppearance()
//        
//        // Start monitoring reachability
//        self.monitorReachability()
//        
//        // Init view controllers
//        self.welcomeViewController = PAPWelcomeViewController()
//        self.navController = UINavigationController(rootViewController: self.welcomeViewController)
//        self.navController.navigationBarHidden = true
//        
//        // Set window root view controller
//        self.window?.rootViewController = self.navController
//        self.window?.makeKeyAndVisible()
//        
//        // Handle push notification
//        self.handlePush(launchOptions)
        
        if let navController = self.window?.rootViewController as? UINavigationController {
            self.rootNavController = navController
        }
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - PFLoginViewController
    
    func logInViewController(logInController: PFLogInViewController, didLogInUser user: PFUser) {
        // user has logged in - we need to fetch all of their Facebook data before we let them in
        if (!self.shouldProceedToMainInterface(user)) {
            let hud = MBProgressHUD.showHUDAddedTo(self.rootNavController.visibleViewController!.view, animated: true)
            hud.labelText = "Loading"
            hud.dimBackground = true
        }

        //
        if (FBSDKAccessToken.currentAccessToken() != nil) {
            let graphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields" : "name,email,friends"])
            graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
                if(error != nil) {
                    print(error)
                }
                else {
                    if let userData = result as? NSDictionary {
                        self.createUserProfile(result)
                        self.followFacebookFriends(result)
                    }
                }
            })
        }
        
        // Subscribe to private push channel
//        if (user) {
//            NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
//            [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kPAPInstallationUserKey];
//            [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kPAPInstallationChannelsKey];
//            [[PFInstallation currentInstallation] saveEventually];
//            [user setObject:privateChannelName forKey:kPAPUserPrivateChannelKey];
//        }
    }
    
    // MARK: - AppDelegate
    
    func isParseReachable() -> Bool {
//        switch(self.networkStatus) {
//            case NetworkStatus.NotReachable:
//                return false
//            case NetworkStatus.ReachableViaWiFi:
//                return true
//            case NetworkStatus.ReachableViaWWAN:
//                reutnr true
//        }
        return true
        
    }
    
    // MARK: - ()
    
    func shouldProceedToMainInterface(user: PFUser) -> Bool {
        if (PAPUtility.userHasValidFacebookData(user)) {
            //MBProgressHUD.hideHUDForView(self.rootNavController.visibleViewController.view, animated: true)
            
            self.rootNavController.visibleViewController!.dismissViewControllerAnimated(true, completion: { () -> Void in
                self.rootNavController.visibleViewController!.performSegueWithIdentifier("showTabBarController", sender: self)
            })
            
            return true
        }
        
        return false
    }
    
    func createUserProfile(result: AnyObject) {
        
        if let facebookID = result.objectForKey("id") as? String {
            PFUser.currentUser()?.setObject(facebookID, forKey: kPAPUserFacebookIDKey)
        }
        
        if let facebookName = result.objectForKey("name") as? String {
            PFUser.currentUser()?.setObject(facebookName, forKey: kPAPUserDisplayNameKey)
        }
    }

    func followFacebookFriends(result: AnyObject) {
        print("To-DO: Follow facebook friends")
    }
}

