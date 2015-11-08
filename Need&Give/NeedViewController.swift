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

class NeedViewController: UITableViewController {
    var refresher:UIRefreshControl!
    var postArr:[PFObject] = []
    var selectRow: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        initUI()
        refreshSelector()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
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
        //Throw a query to the server, note it'll run in background, and when the data is ready, the code inside this query will be called to update UI
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.refresher.endRefreshing()
            if (error == nil) {
                self.postArr.removeAll()
                for re in result! {
                    self.postArr.append(re)
                }
                self.tableView.reloadData()
            }else{
                print("gg")
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return postArr.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("GivenCell", forIndexPath: indexPath) as! ListedCell
        cell.initWithResult(postArr[indexPath.row])

        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectRow = indexPath.row
        print(selectRow)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "detailReveal" {
            let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            let controller = segue.destinationViewController as! DetailViewController
            controller.post = postArr[(selectedIndex?.row)!]
        }
    }
}
