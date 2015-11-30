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
    
    var imageDownloaded: UIImage?
    
    func initWithResult(result: GivenItem!) {
        dispatch_async(dispatch_get_main_queue(), {
            self.givenName.text = result.name
            self.location.text = result.location
            self.organization.text = result.organization
            self.givenImageView.frame = CGRect(x: 15, y: 10, width: 80, height: 80)
            self.givenImageView.image = result.image
        })
    }
}
