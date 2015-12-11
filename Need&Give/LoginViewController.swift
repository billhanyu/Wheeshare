//
//  LoginViewController.swift
//  Need&Give
//
//  Created by Bill Yu on 12/5/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import UIKit
import ParseFacebookUtilsV4

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onClickLoginButton(sender: AnyObject) {
        PFFacebookUtils.logInInBackgroundWithReadPermissions(["email", "public_profile"]) {
            (user: PFUser?, error: NSError?) -> Void in
            if let user = user {
                if user.isNew {
                    print("User signed up and logged in through Facebook!")
                } else {
                    print("User logged in through Facebook!")
                }
                
                let request = FBSDKGraphRequest(graphPath:"me", parameters:nil)
                // Send request to Facebook
                request.startWithCompletionHandler {
                    (connection, result, error) in
                    
                    if error != nil {
                        // Some error checking here
                    }
                    else if let userData = result as? [String:AnyObject] {
                        
                        let username = userData["name"] as? String
                        if let username = username {
                            user.username = username
                        }
                        
                        let emailAddress = userData["email"] as? String
                        if let emailAddress = emailAddress {
                            user.email = emailAddress
                        }
                        
                        let facebookID = userData["id"] as! String
                        print(facebookID)
                        let pictureURL = "https://graph.facebook.com/\(facebookID)/picture?width=320&height=320"
                        
                        let URLRequest = NSURL(string: pictureURL)
                        let URLRequestNeeded = NSURLRequest(URL: URLRequest!)
                        
                        NSURLConnection.sendAsynchronousRequest(URLRequestNeeded, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?, data: NSData?, error: NSError?) -> Void in
                            if error == nil {
                                if let data = data {
                                    let picture = PFFile(name: "profilePic.png", data: data)
                                    user["profilePic"] = picture
                                    user.saveInBackground()
                                }
                            }
                            else {
                                print("Error: \(error)")
                            }
                        })
                        user.saveInBackground()
                    }
                }
                self.dismissViewControllerAnimated(true, completion: nil)
            } else {
                print("Uh oh. The user cancelled the Facebook login.")
            }
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
