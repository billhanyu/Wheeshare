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
    
    func configureWithPFObject(given: PFObject!) {
        name = given[AppKeys.ItemProperties.name] as! String?
        detail = given[AppKeys.ItemProperties.description] as! String?
        category = given[AppKeys.ItemProperties.category] as! String?
        condition = given[AppKeys.ItemProperties.condition] as! String?
        
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
    }
}