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
	let emailButton = UIButton()
	let requestedLabel = UILabel()
	let approvedLabel = UILabel()
	let query = PFUser.query()!
    
    var item: GivenItem!
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
		
		// email button
		emailButton.setTitle("email", forState: .Normal)
		emailButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
		emailButton.backgroundColor = UIColor(red: 25/255, green: 95/255, blue: 88/255, alpha: 1)
		emailButton.layer.cornerRadius = 10.0
		emailButton.frame = CGRect(origin: CGPoint(x: view.bounds.width / 10 * 3, y: view.bounds.height / 10 * 7), size: CGSize(width: view.bounds.width / 5 * 2, height: 50))
		emailButton.addTarget(self, action: Selector("email"), forControlEvents: UIControlEvents.TouchUpInside)
		
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
        navigationItem.title = item.name
        categoryNameLabel.text = item.category
        conditionStatus.text = item.condition
        contentLabel.text = item.detail
        requestButton.enabled = true
		imageView.layer.cornerRadius = 20.0
        
        if item.requester == PFUser.currentUser() {
			if let owner = item.owner {
				self.mailAddress = owner.email
				self.view.addSubview(self.emailButton)
			}
			
            if item.connected {
                view.addSubview(approvedLabel)
            }
            else {
                view.addSubview(requestedLabel)
            }
        }
        else if item.owner == PFUser.currentUser() {
			if let requester = item.requester {
				self.mailAddress = requester.email
				self.view.addSubview(self.emailButton)
			}
			
            if item.connected {
                view.addSubview(approvedLabel)
            }
            else {
                view.addSubview(approveButton)
            }
        }
		else {
			view.addSubview(requestButton)
		}
        
        let imageFile = item.image
        
        if let imageFile = imageFile {
			self.imageView.image = imageFile
        }
        
        view.layoutIfNeeded()
    }
    
    func borrowRequest() {
        let user = PFUser.currentUser()
        
        // save the request in user
        item.result[AppKeys.ItemRelationship.requester] = user!
        item.result.saveInBackground()
		item.requester = user!
        
        self.noticeSuccess("Requested!", autoClear: true, autoClearTime: 1)
		
		UIView.animateWithDuration(0.33, delay: 0.0, options: [.CurveEaseInOut], animations: {
				self.requestButton.removeFromSuperview()
			}, completion: { _ in
				self.view.addSubview(self.requestedLabel)
		})

        // notify the lender
    }
    
    func borrowApprove() {
        item.result[AppKeys.ItemRelationship.connected] = true
        item.result.saveInBackground()
		item.connected = true
		
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
	
	func email() {
		let mailVC = configuredMailComposeViewController()
		presentViewController(mailVC, animated: true, completion: nil)
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