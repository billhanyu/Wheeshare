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
	
	var currentButton: UIButton?
	let requestButton = UIButton()
	let approveButton = UIButton()
	let requestedLabel = UILabel()
	let approvedLabel = UILabel()
    
    var item: PFObject!
    var mailAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapImageGesture = UITapGestureRecognizer(target: self, action: Selector("showImage"))
		imageView.userInteractionEnabled = true
        imageView.addGestureRecognizer(tapImageGesture)
		setupButtons()
        updateUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        updateUI()
    }
	
	private func setupButtons() {
		// request button
		requestButton.setTitle("Request", forState: .Normal)
		requestButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
		requestButton.backgroundColor = UIColor(red: 0.0, green: 200.0, blue: 50.0, alpha: 1.0)
		requestButton.layer.cornerRadius = 10.0
		requestButton.frame = CGRect(origin: CGPoint(x: view.bounds.width / 10 * 3, y: view.bounds.height / 5 * 4), size: CGSize(width: view.bounds.width / 5 * 2, height: 50))
		requestButton.addTarget(self, action: Selector("borrowRequest"), forControlEvents: UIControlEvents.TouchUpInside)
		
		// approve button
		approveButton.setTitle("Approve", forState: .Normal)
		approveButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
		approveButton.backgroundColor = UIColor(red: 0.0, green: 200.0, blue: 50.0, alpha: 1.0)
		approveButton.layer.cornerRadius = 10.0
		approveButton.frame = CGRect(origin: CGPoint(x: view.bounds.width / 10 * 3, y: view.bounds.height / 5 * 4), size: CGSize(width: view.bounds.width / 5 * 2, height: 50))
		approveButton.addTarget(self, action: Selector("borrowApprove"), forControlEvents: UIControlEvents.TouchUpInside)
		
		// requested label
		requestedLabel.textColor = UIColor.whiteColor()
		requestedLabel.text = "I Requested"
		requestedLabel.textAlignment = .Center
		requestedLabel.backgroundColor = UIColor.darkGrayColor()
		requestedLabel.layer.cornerRadius = 10.0
		requestedLabel.clipsToBounds = true
		requestedLabel.frame = CGRect(origin: CGPoint(x: view.bounds.width / 10 * 3, y: view.bounds.height / 5 * 4), size: CGSize(width: view.bounds.width / 5 * 2, height: 50))
		
		// approved label
		approvedLabel.textColor = UIColor.whiteColor()
		approvedLabel.text = "Approved"
		approvedLabel.textAlignment = .Center
		approvedLabel.backgroundColor = UIColor.darkGrayColor()
		approvedLabel.layer.cornerRadius = 10.0
		approvedLabel.clipsToBounds = true
		approvedLabel.frame = CGRect(origin: CGPoint(x: view.bounds.width / 10 * 3, y: view.bounds.height / 5 * 4), size: CGSize(width: view.bounds.width / 5 * 2, height: 50))
	}
    
    func updateUI() {
        navigationItem.title = item[AppKeys.ItemProperties.name] as! String?
        categoryNameLabel.text = item[AppKeys.ItemProperties.category] as! String?
        conditionStatus.text = item[AppKeys.ItemProperties.condition] as! String?
        contentLabel.text = item[AppKeys.ItemProperties.description] as! String?
        requestButton.enabled = true
        
        if item[AppKeys.ItemRelationship.requester] as? PFUser == PFUser.currentUser() {
            if item[AppKeys.ItemRelationship.connected] as! Bool {
                view.addSubview(approvedLabel)
            }
            else {
                view.addSubview(requestedLabel)
            }
        }
        else if item[AppKeys.ItemRelationship.requestedLender] as? PFUser == PFUser.currentUser() {
            if item[AppKeys.ItemRelationship.connected] as! Bool {
                view.addSubview(approvedLabel)
            }
            else {
                view.addSubview(approveButton)
            }
        }
		else {
			view.addSubview(requestButton)
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
    
    func borrowRequest() {
        let user = PFUser.currentUser()
        
        // save the request in user
        item[AppKeys.ItemRelationship.requester] = user!
        item.saveInBackground()
        
        let giver = item[AppKeys.ItemRelationship.owner] as! PFUser
        item[AppKeys.ItemRelationship.requestedLender] = giver
        item.saveInBackground()
        
        self.noticeSuccess("Requested!", autoClear: true, autoClearTime: 1)
		
		UIView.animateWithDuration(0.33, delay: 0.0, options: [.CurveEaseInOut], animations: {
				self.requestButton.removeFromSuperview()
			}, completion: { _ in
				self.view.addSubview(self.requestedLabel)
		})

        // notify the lender
    }
    
    func borrowApprove() {
        item[AppKeys.ItemRelationship.connected] = true
        item.saveInBackground()
		
		self.noticeSuccess("Approved!", autoClear: true, autoClearTime: 1)
		
		UIView.animateWithDuration(0.33, delay: 0.0, options: [.CurveEaseInOut], animations: {
			self.approveButton.removeFromSuperview()
			}, completion: { _ in
				self.view.addSubview(self.approvedLabel)
		})
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
    
    func showImage() {
		if let itemImage = imageView.image {
			let imageVC = storyboard!.instantiateViewControllerWithIdentifier("ImageViewController") as! ImageViewController
			imageVC.image = itemImage
			self.presentViewController(imageVC, animated: true, completion: nil)
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