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

class NeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var refresher:UIRefreshControl!
    var postArr: [PFObject] = []
    var givenItems: [GivenItem] = []
    
    var selectRow: Int!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var navigationBar: UINavigationBar!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        navigationBar.delegate = self
        
        initUI()
        refreshSelector()
        tableView.reloadData()
    }
    
    func initUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        //init pull-to-refresh
        refresher = UIRefreshControl()
        refresher.addTarget(self, action: Selector("refreshSelector"), forControlEvents: UIControlEvents.ValueChanged)
        tableView.addSubview(refresher)
    }
    
    func refreshSelector() {
        let query = PFQuery(className: "Needs")
        query.orderByDescending("createdAt")
        
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.refresher.endRefreshing()
            if (error == nil) {
                self.givenItems.removeAll()
                for given in result! {
                    let givenItem = GivenItem.configureWithPFObject(given)
                    self.givenItems.append(givenItem)
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
            else {
                print("failed to download data")
            }
        }
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
