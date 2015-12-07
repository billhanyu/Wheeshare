//
//  GiveViewController.swift
//  Need&Give
//
//  Created by Bill Yu on 11/7/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import UIKit
import Parse
import Bolts

class GiveViewController: UITableViewController {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var detail: UITextField!
    @IBOutlet weak var location: UITextField!
    @IBOutlet weak var organization: UITextField!
    @IBOutlet weak var mailAddress: UITextField!
    @IBOutlet weak var phoneNumber: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var imageSelected: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var conditionLabel: UILabel!
    
    var image: UIImage?
    var categoryName = "Electronics"
    var conditionName = "New"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var frameRect: CGRect = detail.frame;
        frameRect.size.height = 75;
        detail.frame = frameRect;
        categoryLabel.text = categoryName
        conditionLabel.text = conditionName
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if indexPath != nil && indexPath!.section == 0 && indexPath!.row == 0
        {
            return
        }
        
        name.resignFirstResponder()
    }
    
    func hud() {
        print("supposed to be showing hud")
        
        let hudView = HudView.hudInView(self.view, animated: true)
        hudView.text = "Given!"
        afterDelay(0.6, closure: {
            print("delaying")
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            name.becomeFirstResponder()
        case (0, 3):
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
            pickPhoto()
        default:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 3 {
            if imageSelected.hidden {
                return 44
            }
            else {
                return 280
            }
        }
        if indexPath.section == 0 && indexPath.row == 2 {
            return 88
        }
        return 44
    }
    
    @IBOutlet weak var imageLeadingMargin: NSLayoutConstraint!
    @IBOutlet weak var imageCenterY: NSLayoutConstraint!
    @IBOutlet weak var imageTop: NSLayoutConstraint!
    @IBOutlet weak var imageRatio: NSLayoutConstraint!
    
    func showImage(image: UIImage) {
        imageSelected.image = image
        imageSelected.hidden = false
        imageLeadingMargin.constant = 8
        imageTop.constant = 11
        imageCenterY.active = false
        imageRatio.constant = 1
        addPhotoLabel.hidden = true
        view.layoutIfNeeded()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PickCondition" {
            let controller = segue.destinationViewController.childViewControllers[0] as! PickConditionViewController
            controller.conditionName = conditionName
        }
        if segue.identifier == "PickCategory" {
            let controller = segue.destinationViewController.childViewControllers[0] as! PickCategoryViewController
            controller.categoryName = categoryName
        }
        if segue.identifier == "Given" {
            /*
            dispatch_async(dispatch_get_main_queue()) {
                self.hud()
            }*/
            
            var imageFile: PFFile?
            if let image = image {
                let imageData = image.mediumQualityJPEGNSData
                imageFile = PFFile(name:"image.png", data:imageData)
            }
            let given = PFObject(className:"Needs")
            given["Name"] = name.text
            given["detail"] = detail.text
            given["location"] = location.text
            given["organization"] = organization.text
            given["mailAddress"] = mailAddress.text
            given["phoneNumber"] = phoneNumber.text
            given["category"] = categoryLabel.text
            given["condition"] = conditionLabel.text
            if let imageFile = imageFile {
                given["image"] = imageFile
            }
            given.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                if (success) {
                    print("Given object info saved")
                } else {
                    print("Given object info saving failure")
                }
            }
        }
    }
    
    @IBAction func conditionPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! PickConditionViewController
        conditionName = controller.conditionName
        conditionLabel.text = conditionName
    }
    
    @IBAction func categoryPickerDidPickCategory(segue: UIStoryboardSegue) {
        let controller = segue.sourceViewController as! PickCategoryViewController
        categoryName = controller.categoryName
        categoryLabel.text = categoryName
    }
}

extension GiveViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        image = info[UIImagePickerControllerEditedImage] as? UIImage
        if let image = image {
            showImage(image)
        }
    
        dismissViewControllerAnimated(true, completion: nil)
    
        tableView.reloadData()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func pickPhoto() {
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            showPhotoMenu()
        }
        else {
            choosePhotoFromLibrary()
        }
    }
    
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {_ in self.takePhotoWithCamera()})
        alertController.addAction(takePhotoAction)
        
        let chooseFromLibraryAction = UIAlertAction(title: "Choose From Library", style: .Default, handler: {_ in self.choosePhotoFromLibrary()})
        alertController.addAction(chooseFromLibraryAction)
        
        alertController.view.tintColor = UIColor.blackColor()
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}
