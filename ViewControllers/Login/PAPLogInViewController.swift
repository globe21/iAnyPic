//
//  PAPLogInViewController.swift
//  iAnyPic
//
//  Created by Xiao Jiang on 8/26/15.
//  Copyright (c) 2015 Xiao Jiang. All rights reserved.
//

import UIKit
import ParseUI

class PAPLogInViewController: PFLogInViewController {

    @IBOutlet weak var bgImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Load background image
        if let backgroundImage = UIImage(named: "Default.png") {
            let imageView = UIImageView(image: backgroundImage)
            imageView.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            imageView.contentMode = UIViewContentMode.ScaleAspectFill
            imageView.clipsToBounds = true
            self.logInView!.insertSubview(imageView, atIndex: 0)
        }
        
        let text = "Sign up and start sharing your story with your friends."
        
        // Get the size of the text
        let maximumLabelSize = CGSizeMake(255.0, CGFloat.max)
        let options: NSStringDrawingOptions = [NSStringDrawingOptions.TruncatesLastVisibleLine, NSStringDrawingOptions.UsesLineFragmentOrigin]
        let attribute = [NSFontAttributeName: UIFont.systemFontOfSize(15)]
        let labelBounds = text.boundingRectWithSize(maximumLabelSize, options: options, attributes: attribute, context: nil)
        
        // Init text label
        let textLabel = UILabel(frame: CGRectMake( (UIScreen.mainScreen().bounds.size.width - labelBounds.width) / 2.0, 260.0, labelBounds.width, labelBounds.height))
        textLabel.font = UIFont(name: "HelveticaNeue-Medium", size: 18.0)
        textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        textLabel.numberOfLines = 0
        textLabel.text = text
        textLabel.textColor = UIColor(red: 214.0/255.0, green: 206.0/255.0, blue: 191.0/255.0, alpha: 1.0)
        textLabel.backgroundColor = UIColor.clearColor()
        textLabel.textAlignment = NSTextAlignment.Center
        
        if let theLogInView = self.logInView {
            theLogInView.logo = nil
            theLogInView.addSubview(textLabel)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        if let facebookButton = self.logInView!.facebookButton {
            facebookButton.frame = CGRectMake((UIScreen.mainScreen().bounds.width - facebookButton.bounds.size.width) / 2.0, UIScreen.mainScreen().bounds.height - 350.0, facebookButton.bounds.size.width, facebookButton.bounds.size.height)
        }
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
