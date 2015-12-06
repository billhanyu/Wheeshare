//
//  UIImage+Compress.swift
//  Need&Give
//
//  Created by Bill Yu on 11/30/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    var uncompressedPNGData: NSData {
        return UIImagePNGRepresentation(self)!
    }
    var highestQualityJPEGNSData: NSData {
        return UIImageJPEGRepresentation(self, 1.0)!
    }
    var highQualityJPEGNSData: NSData {
        return UIImageJPEGRepresentation(self, 0.75)!
    }
    var mediumQualityJPEGNSData: NSData {
        return UIImageJPEGRepresentation(self, 0.5)!
    }
    var lowQualityJPEGNSData: NSData {
        return UIImageJPEGRepresentation(self, 0.25)!
    }
    var lowestQualityJPEGNSData:NSData {
        return UIImageJPEGRepresentation(self, 0.0)!
    }
}