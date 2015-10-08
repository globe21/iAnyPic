//
//  PAPAccountViewController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 10/6/15.
//  Copyright © 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import Parse

class PAPAccountViewController: PAPPhotoTimelineViewController {
    
    var user: PFUser!
    
    var headerView: UIView!
    
    // MARK: - UIViewController

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "LogoNavigationBar.png"))
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
