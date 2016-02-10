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
    @IBOutlet weak var starImageView: UIImageView!
    
    func initWithResult(result: PFObject) {
        self.givenName.text = result["Name"] as! String?
        self.statusLabel.text = ""
        self.givenImageView.frame = CGRect(x: 15, y: 10, width: 80, height: 80)
        
        let imageFile = result["image"] as? PFFile
        
        let isGiver = result[AppKeys.ItemRelationship.owner] as? PFUser == PFUser.currentUser()
        let borrowUser = result[AppKeys.ItemRelationship.requester] as? PFUser
        let connected = result[AppKeys.ItemRelationship.connected] as! Bool
        
        if isGiver {
            starImageView.hidden = false
            if let borrower = borrowUser {
                let query = PFUser.query()!
                query.getObjectInBackgroundWithId(borrower.objectId!, block: { (requester, error) -> Void in
                    self.statusLabel.text = connected ? "lended to " : "requested by "
                    if let requester = requester as? PFUser{
                        self.statusLabel.text! += requester == PFUser.currentUser() ? "me" : String(requester.username!)
                    }
                })
            }
        }
        
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
