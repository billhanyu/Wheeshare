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
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var navigationBar: UINavigationBar!
    
    var item: PFObject!
    var mailAddress: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationBar.delegate = self
        updateUI()
        // Do any additional setup after loading the view.
    }
    
    @IBAction func mail(sender: AnyObject) {
        mailAddress = emailButton.titleLabel?.text
        if let _ = mailAddress {
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.presentViewController(mailComposeViewController, animated: true, completion: nil)
            } else {
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
        emailButton.setTitle(item["mailAddress"] as! String?, forState: .Normal)
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
    }

}

extension DetailViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}