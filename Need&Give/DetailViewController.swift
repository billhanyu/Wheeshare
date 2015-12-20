//
//  DetailViewController.swift
//  Need&Give
//
//  Created by Bill Yu on 11/8/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import UIKit
import Parse
import Bolts
import MessageUI

class DetailViewController: UIViewController, MFMailComposeViewControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryNameLabel: UILabel!
    @IBOutlet weak var conditionStatus: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var requestButton: UIButton!
    
    var item: PFObject!
    var mailAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.delegate = self
        updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        updateUI()
    }
    
    func mail() {
        if let _ = mailAddress {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            }
            else {
                self.showSendMailErrorAlert()
            }
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([mailAddress!])
        mailComposerVC.setSubject("I need this...")
        if let stuffName = navigationBar.topItem?.title {
            mailComposerVC.setMessageBody("I need \(stuffName)", isHTML: false)
        }
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onClickDone(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateUI() {
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        navigationBar.topItem?.title = item["Name"] as! String?
        categoryNameLabel.text = item["category"] as! String?
        conditionStatus.text = item["condition"] as! String?
        contentLabel.text = item["detail"] as! String?
        mailAddress = item["mailAddress"] as! String?
        requestButton.enabled = true
        
        if item["requester"] as? PFUser == PFUser.currentUser() {
            if item["connected"] as! Bool {
                requestButton.setTitle("Approved", forState: .Disabled)
            }
            else {
                requestButton.setTitle("I requested", forState: .Disabled)
            }
        }
        if item["requestedLender"] as? PFUser == PFUser.currentUser() {
            if item["connected"] as! Bool {
                requestButton.setTitle("Approved", forState: .Disabled)
            }
            else {
                requestButton.setTitle("Approve", forState: .Normal)
            }
        }
        
        let imageFile = item["image"] as? PFFile
        
        if let imageFile = imageFile {
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        dispatch_async(dispatch_get_main_queue(), {
                            self.imageView.image = UIImage(data:imageData)
                        })
                    }
                }
            }
        }
        
        view.layoutIfNeeded()
    }
    
    @IBAction func requestButtonClicked(sender: AnyObject) {
        if requestButton.titleLabel?.text == "Borrow Request" {
            borrowRequest()
        }
        else if requestButton.titleLabel?.text == "Approve" {
            borrowApprove()
        }
    }
    
    func borrowRequest() {
        // save the request in user
        item["requester"] = PFUser.currentUser()
        item.saveInBackground()
        
        let user = PFUser.currentUser()
        user!["borrowRequest"] = item
        user!.saveInBackgroundWithBlock { (success, error) -> Void in
            if !success || error != nil {
                let alert = UIAlertController(title: "Error", message: "Please try again later.", preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
                return
            }
            let alert = UIAlertController(title: "Requested!", message: "Wanna Email the owner?", preferredStyle: .Alert)
            let emailAction = UIAlertAction(title: "Email", style: .Default, handler: { _ in
                self.mail()
            })
            let cancelAction = UIAlertAction(title: "No", style: .Cancel, handler: nil)
            alert.addAction(emailAction)
            alert.addAction(cancelAction)
            self.presentViewController(alert, animated: true, completion: nil)
            self.updateUI()
        }
        
        let giver = item["giver"] as! PFUser
        giver["requestedLend"] = item
        giver.saveInBackground()
        
        item["requestedLender"] = giver
        item.saveInBackground()
        
        // notify the lender
    }
    
    func borrowApprove() {
        item["connected"] = true
        item.saveInBackground()
        // notify the requester
    }

}

extension DetailViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}