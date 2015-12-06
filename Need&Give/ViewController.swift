//
//  ViewController.swift
//  Need&Give
//
//  Created by Bill Yu on 11/7/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import UIKit
import Parse
import Bolts
import CoreData

class ViewController: UITabBarController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        if PFUser.currentUser() == nil {
            print("current user is nil")
            let controller = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
            self.presentViewController(controller, animated: true, completion: nil)
            return
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func GiverDidGive(segue: UIStoryboardSegue) {
    }
}

