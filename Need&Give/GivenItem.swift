//
//  GivenItem.swift
//  Need&Give
//
//  Created by Bill Yu on 11/30/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Bolts

class GivenItem {
    var name: String?
    var detail: String?
    var location: String?
    var organization: String?
    var mailAddress: String?
    var phoneNumber: String?
    var category: String?
    var image: UIImage?
    var condition: String?
    
    func configureWithPFObject(given: PFObject!) {
        name = given["Name"] as! String?
        detail = given["detail"] as! String?
        location = given["location"] as! String?
        organization = given["organization"] as! String?
        mailAddress = given["mailAddress"] as! String?
        phoneNumber = given["phoneNumber"] as! String?
        category = given["category"] as! String?
        condition = given["condition"] as! String?
        
        let imageFile = given["image"] as? PFFile

        if let imageFile = imageFile {
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.image = UIImage(data:imageData)
                    }
                }
            }
        }
    }
}