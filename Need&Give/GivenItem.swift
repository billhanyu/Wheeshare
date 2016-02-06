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
    var category: String?
    var image: UIImage?
    var condition: String?
    var requester: PFUser?
    var owner: PFUser?
    var connected: Bool = false
    
    var result: PFObject! = nil {
        didSet {
            configureWithPFObject(result)
        }
    }
    
    func configureWithPFObject(given: PFObject!) {
        name = given[AppKeys.ItemProperties.name] as! String?
        detail = given[AppKeys.ItemProperties.description] as! String?
        category = given[AppKeys.ItemProperties.category] as! String?
        condition = given[AppKeys.ItemProperties.condition] as! String?
        result = given
        
        let imageFile = given[AppKeys.ItemProperties.image] as? PFFile

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
        
        let borrowUser = given[AppKeys.ItemRelationship.requester] as? PFUser
        if let borrowUser = borrowUser {
            let query = PFUser.query()!
            query.getObjectInBackgroundWithId(borrowUser.objectId!, block: { (borrower, error) -> Void in
                if let borrower = borrower as? PFUser {
                    self.requester = borrower
                }
            })
        }
        
        let lendUser = given[AppKeys.ItemRelationship.owner] as? PFUser
        if let lendUser = lendUser {
            let query = PFUser.query()!
            query.getObjectInBackgroundWithId(lendUser.objectId!, block: { (lender, error) -> Void in
                if let lender = lender as? PFUser {
                    self.owner = lender
                }
            })
        }
        
        connected = given[AppKeys.ItemRelationship.connected] as! Bool
    }
}