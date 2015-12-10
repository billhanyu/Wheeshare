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
    
    func initWithResult(result: PFObject) {
        self.givenName.text = result["Name"] as! String?
        self.location.text = result["location"] as! String?
        self.givenImageView.frame = CGRect(x: 15, y: 10, width: 80, height: 80)
        
        let imageFile = result["image"] as? PFFile
        
        if let imageFile = imageFile {
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        self.givenImageView.image = UIImage(data:imageData)
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        givenName.text = nil
        location.text = nil
        givenImageView.image = nil
    }
}
