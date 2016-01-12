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
    @IBOutlet weak var requestButton: UIButton!
    
    var item: PFObject!
    var mailAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        updateUI()
    }
    
    func updateUI() {
        navigationItem.title = item[AppKeys.ItemProperties.name] as! String?
        categoryNameLabel.text = item[AppKeys.ItemProperties.category] as! String?
        conditionStatus.text = item[AppKeys.ItemProperties.condition] as! String?
        contentLabel.text = item[AppKeys.ItemProperties.description] as! String?
        requestButton.enabled = true
        
        if item[AppKeys.ItemRelationship.requester] as? PFUser == PFUser.currentUser() {
            if item[AppKeys.ItemRelationship.connected] as! Bool {
                requestButton.titleLabel?.text = "Approved"
                print("approved")
            }
            else {
                requestButton.titleLabel?.text = "I requested"
            }
        }
        if item[AppKeys.ItemRelationship.requestedLender] as? PFUser == PFUser.currentUser() {
            if item[AppKeys.ItemRelationship.connected] as! Bool {
                requestButton.titleLabel?.text = "Approved"
            }
            else {
                requestButton.titleLabel?.text = "Approve"
            }
        }
        
        let imageFile = item[AppKeys.ItemProperties.image] as? PFFile
        
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
        let user = PFUser.currentUser()
        
        // save the request in user
        item[AppKeys.ItemRelationship.requester] = user!
        item.saveInBackground()
        
        let giver = item[AppKeys.ItemRelationship.owner] as! PFUser
        item[AppKeys.ItemRelationship.requestedLender] = giver
        item.saveInBackground()
        
        self.noticeSuccess("Requested!", autoClear: true, autoClearTime: 1)

        // notify the lender
    }
    
    func borrowApprove() {
        item[AppKeys.ItemRelationship.connected] = true
        item.saveInBackground()
        // notify the requester
    }
    
    func mail() {
        if let _ = mailAddress {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            }
            else {
                print("error")
            }
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients([mailAddress!])
        mailComposerVC.setSubject("I need this...")
        if let stuffName = navigationItem.title {
            mailComposerVC.setMessageBody("I need \(stuffName)", isHTML: false)
        }
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }
}