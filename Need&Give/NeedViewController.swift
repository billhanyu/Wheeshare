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

enum ShareCategory: Int {
    case BorrowRequest = 0
    case Borrow = 1
    case LendRequest = 2
    case Lend = 3
    
    var categoryName: String {
        switch self {
        case .BorrowRequest:
            return "borrowRequest"
        case .Borrow:
            return "borrow"
        case .LendRequest:
            return "lendRequest"
        case .Lend:
            return "lend"
        }
    }
}

enum State {
    case NotSearchedYet
    case Loading
    case NoResults
    case Results
}
private(set) var state: State = .NotSearchedYet

class NeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var refresher:UIRefreshControl!
    var givenItems: [PFObject] = []
    
    var selectRow: Int!
    var showShare: Bool = false
    var currentUser: PFUser?
    
    var shareCategory: ShareCategory = .BorrowRequest
    
    var doneButton = UIBarButtonItem(title: "Done", style: .Done, target: nil, action: Selector("dismiss"))
    
    var firstTime = true
    
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var shareDone: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib = UINib(nibName: "LoadingCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "LoadingCell")
        
        doneButton.target = self
        currentUser = PFUser.currentUser()
        initUI()
        //refreshSelector()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        refreshSelector()
        if let _ = PFUser.currentUser() {
            fillTelNumber()
        }
        
        // no as showshareVC
        if (!showShare) {
            segmentedControl.hidden = true
            tableViewTop.constant = 0
            tableViewBottom.constant = 49
            title = "Borrow"
            tableView.reloadData()
            self.navigationItem.rightBarButtonItem = nil
        }
        else {
            segmentedControl.hidden = false
            tableViewTop.constant = 39
            tableViewBottom.constant = 0
            title = "My Shares"
            tableView.reloadData()
            self.navigationItem.rightBarButtonItem = doneButton
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
        state = .Loading
        if firstTime {
            tableView.reloadData()
            firstTime = false
        }
        
        var query: PFQuery!
        query = PFQuery(className: "Needs")
        query.orderByDescending("createdAt")
        //query.cachePolicy = .CacheElseNetwork
        
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            if (error == nil) {
                if !self.showShare {
                    self.givenItems.removeAll()
                    for given in result! {
                        self.givenItems.append(given)
                    }
                }
                else {
                    self.givenItems.removeAll()
                    for given in result! {
                        let borrowUser = given["requester"] as? PFUser == self.currentUser
                        let connected = given["connected"] as! Bool
                        let lendUser = given["requestedLender"] as? PFUser == self.currentUser
                        switch self.shareCategory{
                        case .BorrowRequest:
                            if borrowUser && !connected {
                                self.givenItems.append(given)
                            }
                        case .LendRequest:
                            if lendUser && !connected {
                                self.givenItems.append(given)
                            }
                        case .Borrow:
                            if borrowUser && connected {
                                self.givenItems.append(given)
                            }
                        case .Lend:
                            if lendUser && connected {
                                self.givenItems.append(given)
                            }
                        }
                    }
                }
                if self.givenItems.count > 0 {
                    state = .Results
                }
                else {
                    state = .NoResults
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
    
    @IBAction func segmentChanged(sender: AnyObject) {
        shareCategory = ShareCategory(rawValue:segmentedControl.selectedSegmentIndex)!
        refreshSelector()
    }
    
    func dismiss() {
        self.dismissViewControllerAnimated(true, completion: nil)
        print("dismiss")
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
        switch state {
        case .Loading:
            return 1
        case .NoResults:
            return 1
        case .Results:
            return givenItems.count
        default:
            return 0
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch state {
        case .Loading:
            let cell = tableView.dequeueReusableCellWithIdentifier("LoadingCell", forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier("GivenCell", forIndexPath: indexPath) as! ListedCell
            cell.initWithResult(givenItems[indexPath.row])
            return cell
        }
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
