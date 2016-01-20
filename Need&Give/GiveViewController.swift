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

class GiveViewController: UITableViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var detail: UITextField!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var imageSelected: UIImageView!
    @IBOutlet weak var addPhotoLabel: UILabel!
    @IBOutlet weak var conditionSlider: UISlider!
    
    var pickerView = UIPickerView()
    let categories = ["Electronics", "Textbooks", "Toys", "Tools"]
    var expand = false
    
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
    }
    
    func initUI() {
        var frameRect: CGRect = detail.frame;
        frameRect.size.height = 75;
        detail.frame = frameRect;
        pickerView.delegate = self
        categoryLabel.text = categories[0]
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    func flush() {
        name.text = ""
        detail.text = ""
        categoryLabel.text = categories[0]
        imageSelected.image = nil
        imageSelected.hidden = true
        addPhotoLabel.hidden = false
        expand = false
        tableView.reloadData()
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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            name.becomeFirstResponder()
        case (0, 1):
            expand = true
            let cell = tableView.cellForRowAtIndexPath(indexPath)
            cell?.contentView.addSubview(pickerView)
            tableView.reloadData()
        case (0, 4):
            pickPhoto()
        default:
            break
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 1):
            if expand {
                return 200
            }
            return 44
        case (0, 2):
            return 88
        case (0, 3):
            return 80
        case (0, 4):
            if imageSelected.hidden {
                return 44
            }
            return 280
        default:
            return 44
        }
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
        name.becomeFirstResponder()
        view.layoutIfNeeded()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == AppKeys.SegueIdentifiers.lendItem {
            if validateInput() == false {
                return
            }
            self.pleaseWait()
            
            var imageFile: PFFile?
            if let image = image {
                let imageData = image.mediumQualityJPEGNSData
                imageFile = PFFile(name:"image.png", data:imageData)
            }
            let given = PFObject(className:"Needs")
            given[AppKeys.ItemRelationship.owner] = PFUser.currentUser()
            given[AppKeys.ItemProperties.name] = name.text
            given[AppKeys.ItemProperties.description] = detail.text
            given[AppKeys.ItemProperties.category] = categoryLabel.text
            given[AppKeys.ItemRelationship.connected] = false
            var conditionName = ""
            if conditionSlider.value == 100 {
                conditionName = "Perfect"
            }
            else if conditionSlider.value >= 90 {
                conditionName = "Good"
            }
            else if conditionSlider.value >= 70 {
                conditionName = "Fair"
            }
            else {
                conditionName = "Old"
            }
            given[AppKeys.ItemProperties.condition] = conditionName
            if let imageFile = imageFile {
                given[AppKeys.ItemProperties.image] = imageFile
            }
            given.saveInBackgroundWithBlock {
                (success: Bool, error: NSError?) -> Void in
                self.clearAllNotice()
                if (success) {
                    print("Given object info saved")
                    UIView.animateWithDuration(0.0, delay: 0.0, options: [], animations: {
                            self.noticeSuccess("Lended!")
                        }, completion: { _ in
                            delay(seconds: 0.8) {self.clearAllNotice()}
                    })
                } else {
                    print("Given object info saving failure")
                    UIView.animateWithDuration(0.0, delay: 0.0, options: [], animations: {
                        self.noticeError("Error")
                        }, completion: { _ in
                            delay(seconds: 0.8) {self.clearAllNotice()}
                    })
                }
            }
            
            let user = PFUser.currentUser()!
            var ownedObjects = user[AppKeys.User.owned] as! [PFObject]
            ownedObjects.append(given)
            user[AppKeys.User.owned] = ownedObjects
            user.saveInBackground()
            
            flush()
        }
    }
    
    func validateInput() -> Bool {
        if name.text == "" {
            UIView.animateWithDuration(0.0, delay: 0.0, options: [], animations: {
                self.noticeError("Info Needed")
                }, completion: { _ in
                    delay(seconds: 0.8) {self.clearAllNotice()}
            })
            return false
        }
        return true
    }
    
    // MARK: UIPickerView Delegate & DataSource
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        categoryLabel.text = categories[row]
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
