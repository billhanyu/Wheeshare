//
//  UserViewController.swift
//  Need&Give
//
//  Created by Bill Yu on 12/6/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import UIKit
import Parse

class UserViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var telNumLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI() {
        if let name = PFUser.currentUser()?.username {
            nameLabel.text = name
        }
        if let email = PFUser.currentUser()?.email {
            emailLabel.text = email
        }
        
        // set profile picture & phone number
        let query = PFUser.query()
        query?.getObjectInBackgroundWithId((PFUser.currentUser()?.objectId)!, block: {
            (person: PFObject?, error:NSError?) -> Void in
            if let person = person {
                let telNum = person[AppKeys.User.telephone] as? String
                self.telNumLabel.text = telNum
                
                let imageFile = person[AppKeys.User.profilePic]
                if let imageFile = imageFile {
                    imageFile.getDataInBackgroundWithBlock {
                        (imageData: NSData?, error: NSError?) -> Void in
                        if error == nil {
                            if let imageData = imageData {
                                self.profilePic.image = UIImage(data:imageData)
                            }
                        }
                    }
                }
            }
        })
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0: return 4
        default: return 1
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 3 {
            let alert = UIAlertController(title: "Log Out", message: "Are you sure to log out?", preferredStyle: .Alert)
            let cancel = UIAlertAction(title: "cancel", style: .Cancel) { (action: UIAlertAction!) -> Void in
            }
            let logOut = UIAlertAction(title: "Log Out", style: .Default, handler: { (UIAlertAction) -> Void in
                PFUser.logOutInBackgroundWithBlock({ (PFUserLogoutResultBlock) -> Void in
                    let controller = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
                    self.presentViewController(controller, animated: true, completion: nil)
                })
            })
            alert.addAction(cancel)
            alert.addAction(logOut)
            presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == AppKeys.SegueIdentifiers.showShare {
            let needViewController = segue.destinationViewController as! NeedViewController
            
            needViewController.showShare = true
        }
    }
}
