//
//  Functions.swift
//  Need&Give
//
//  Created by Bill Yu on 11/8/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import Foundation
import Dispatch

func afterDelay(seconds: Double, closure: () -> ()) {
    let when = dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC)))
    dispatch_after(when, dispatch_get_main_queue(), closure)
}