//
//  ListedCell.swift
//  Need&Give
//
//  Created by Bill Yu on 11/7/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import Foundation
import UIKit
import Parse
import Bolts

class ListedCell: UITableViewCell {
    
    @IBOutlet weak var givenImageView: UIImageView!
    @IBOutlet weak var givenName: UILabel!
    @IBOutlet weak var location: UILabel!
    @IBOutlet weak var organization: UILabel!
    
    func initWithResult(result: PFObject!) {
        givenName.text = result["Name"] as? String
        location.text = result["location"] as? String
        organization.text = result["organization"] as? String
        
        let imageFile = result["image"] as? PFFile
        if let imageFile = imageFile {
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        let image = UIImage(data:imageData)
                        self.givenImageView.frame = CGRect(x: 15, y: 10, width: 80, height: 80)
                        self.givenImageView.image = image
                    }
                }
            }
        }
    }
}
