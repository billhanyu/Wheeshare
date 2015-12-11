//
//  NeedViewController.swift
//  Need&Give
//
//  Created by Bill Yu on 11/7/15.
//  Copyright © 2015 Bill Yu. All rights reserved.
//

import UIKit
import Parse
import Bolts

typealias DownloadComplete = (Bool) -> Void

class NeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var refresher:UIRefreshControl!
    var givenItems: [PFObject] = []
    
    var selectRow: Int!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        navigationBar.delegate = self
        
        initUI()
        refreshSelector()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewWillAppear(true)
        refreshSelector()
        if let _ = PFUser.currentUser() {
            fillTelNumber()
        }
    }
    
    func fillTelNumber() {
        let user = PFUser.currentUser()
        
        let query = PFUser.query()!
        query.getObjectInBackgroundWithId((user?.objectId)!, block: {
            (person: PFObject?, error:NSError?) -> Void in
            if let person = person {
                let telNum = person["telNum"]
                
                if telNum == nil {
                    let alert = UIAlertController(title: "Telephone Number", message: "Please fill in telephone number as contact info :)", preferredStyle: .Alert)
                    let confirm = UIAlertAction(title: "Confirm", style: .Default, handler: { (UIAlertAction) -> Void in
                        let textField = alert.textFields![0] as UITextField
                        person["telNum"] = textField.text
                        person.saveInBackground()
                    })
                    let textField = UITextField()
                    textField.keyboardType = .NumberPad
                    alert.addTextFieldWithConfigurationHandler {(textField) -> Void in}
                    alert.addAction(confirm)
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }
        })
    }
    
    func initUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        //init pull-to-refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: Selector("refreshSelector"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refresher)
    }
    
    func refreshSelector() {
        let query = PFQuery(className: "Needs")
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            if (error == nil) {
                self.givenItems.removeAll()
                for given in result! {
                    self.givenItems.append(given)
                }
                self.refresher.endRefreshing()
                self.tableView.reloadData()
            }
            else {
                print(error)
                return
            }
        }
        /*
        dispatch_async(dispatch_get_main_queue(), {
            self.refresher.endRefreshing()
            self.tableView.reloadData()
        })*/
    }
    
    func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message: "There was an error reading from the iTunes Store. Please try again.",
            preferredStyle: .Alert)
        
        let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(action)
        
        presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return givenItems.count
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GivenCell", forIndexPath: indexPath) as! ListedCell
        cell.initWithResult(givenItems[indexPath.row])
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectRow = indexPath.row
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "DetailReveal" {
            let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForCell(sender as! UITableViewCell)!, animated: true)
            let controller = segue.destinationViewController as! DetailViewController
            controller.item = givenItems[(selectedIndex?.row)!]
        }
    }
}

extension NeedViewController: UINavigationBarDelegate {
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
}
