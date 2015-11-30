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
    
    static func configureWithPFObject(given: PFObject!) -> GivenItem {
        let givenItem = GivenItem()
        givenItem.name = given["Name"] as! String?
        givenItem.detail = given["detail"] as! String?
        givenItem.location = given["location"] as! String?
        givenItem.organization = given["organization"] as! String?
        givenItem.mailAddress = given["mailAddress"] as! String?
        givenItem.phoneNumber = given["phoneNumber"] as! String?
        givenItem.category = given["category"] as! String?
        givenItem.condition = given["condition"] as! String?
        
        let imageFile = given["image"] as? PFFile
        if let imageFile = imageFile {
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        givenItem.image = UIImage(data:imageData)
                    }
                }
            }
        }
        return givenItem
    }
}