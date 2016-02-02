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
    @IBOutlet weak var statusLabel: UILabel!
    
    func initWithResult(result: PFObject) {
        self.givenName.text = result["Name"] as! String?
        self.statusLabel.text = ""
        self.givenImageView.frame = CGRect(x: 15, y: 10, width: 80, height: 80)
        
        let imageFile = result["image"] as? PFFile
        
        if let imageFile = imageFile {
            imageFile.getDataInBackgroundWithBlock {
                (imageData: NSData?, error: NSError?) -> Void in
                if error == nil {
                    if let imageData = imageData {
                        let data = imageDataScaledToHeight(imageData, height: 120)
                        self.givenImageView.image = UIImage(data: data)
                    }
                }
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        givenName.text = nil
        statusLabel.text = nil
        givenImageView.image = nil
    }
}
