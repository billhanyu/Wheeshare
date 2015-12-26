//
//  Functions.swift
//  Need&Give
//
//  Created by Bill Yu on 11/8/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import Foundation
import Dispatch
import UIKit

func delay(seconds seconds: Double, completion:()->()) {
    let popTime = dispatch_time(DISPATCH_TIME_NOW, Int64( Double(NSEC_PER_SEC) * seconds ))
    
    dispatch_after(popTime, dispatch_get_main_queue()) {
        completion()
    }
}

func imageDataScaledToHeight(imageData: NSData, height: CGFloat) -> NSData {
        
    let image = UIImage(data: imageData)!
    let oldHeight = image.size.height
    let scaleFactor = height / oldHeight
    let newWidth = image.size.width * scaleFactor
    let newSize = CGSizeMake(newWidth, height)
    let newRect = CGRectMake(0, 0, newWidth, height)
    
    UIGraphicsBeginImageContext(newSize)
    image.drawInRect(newRect)
    let newImage =
    UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return UIImageJPEGRepresentation(newImage, 0.8)!
}