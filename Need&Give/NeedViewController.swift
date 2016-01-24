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

enum ShowCategory {
    case ShowShare
    case ShowOwn
    case ShowAll
}

private(set) var state: State = .NotSearchedYet

class NeedViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LoadMoreTableFooterViewDelegate {
    var refresher:UIRefreshControl!
    var givenItems: [PFObject] = []
    
    let ITEM_SINGLE_LOAD_AMOUNT:Int = 15
    var ITEM_SKIP_AMOUNT:Int = 0
    var itemLoadMoreFooterView: LoadMoreTableFooterView!
    var itemAllowLoadingMore = true
    var itemIsLoadingMore: Bool = false
    var itemCouldLoadMore: Bool = false
    var itemQueryCompletionCounter = 0
    
    var selectRow: Int!
    var showCategory: ShowCategory = .ShowAll
    var currentUser: PFUser?
    
    var shareCategory: ShareCategory = .BorrowRequest
    
    var firstTime = true
    
    @IBOutlet weak var tableViewBottom: NSLayoutConstraint!
    @IBOutlet weak var tableViewTop: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var shareDone: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var cellNib = UINib(nibName: AppKeys.CellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: AppKeys.CellIdentifiers.loadingCell)
        cellNib = UINib(nibName: AppKeys.CellIdentifiers.noResultsCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: AppKeys.CellIdentifiers.noResultsCell)
        
        firstTime = true
        currentUser = PFUser.currentUser()
        initUI()
        refreshSelector()
        
        // no as showshareVC
        switch showCategory {
        case .ShowAll:
            segmentedControl.hidden = true
            tableViewTop.constant = 0
            tableViewBottom.constant = 49
            title = "Borrow"
            tableView.reloadData()
        case .ShowShare:
            segmentedControl.hidden = false
            tableViewTop.constant = 39
            tableViewBottom.constant = 0
            title = "My Shares"
            tableView.reloadData()
        case .ShowOwn:
            segmentedControl.hidden = true
            tableViewTop.constant = 0
            title = "My Stuff"
            tableView.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        //refreshSelector()
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
                let telNum = person[AppKeys.User.telephone]
                
                if telNum == nil {
                    let alert = UIAlertController(title: "Telephone Number", message: "Please fill in telephone number as contact info :)", preferredStyle: .Alert)
                    let confirm = UIAlertAction(title: "Confirm", style: .Default, handler: { (UIAlertAction) -> Void in
                        let textField = alert.textFields![0] as UITextField
                        person[AppKeys.User.telephone] = textField.text
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
        
        itemLoadMoreFooterView = LoadMoreTableFooterView(frame: CGRectMake(0, tableView.contentSize.height, tableView.frame.size.width, tableView.frame.size.height))
        itemLoadMoreFooterView.delegate = self
        itemLoadMoreFooterView.backgroundColor = UIColor.clearColor()
        tableView.addSubview(itemLoadMoreFooterView)
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
        query.limit = ITEM_SINGLE_LOAD_AMOUNT
        //query.cachePolicy = PFCachePolicy.CacheThenNetwork
        self.itemQueryCompletionCounter = 0
        
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error: NSError?) -> Void in
            self.itemQueryCompletionCounter++
            self.itemQueryCompletionHandler(result: result, error: error, removeAll: true)
            if self.itemQueryCompletionCounter >= 2 {
                self.itemAllowLoadingMore = true
            }
        }
    }
    
    @IBAction func segmentChanged(sender: AnyObject) {
        shareCategory = ShareCategory(rawValue:segmentedControl.selectedSegmentIndex)!
        refreshSelector()
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
    
    func itemLoadMoreSelector() {
        print("Item Begin Loading More")
        let query = PFQuery(className: "Needs")
        query.orderByDescending("createdAt")
        query.limit = ITEM_SINGLE_LOAD_AMOUNT
        query.skip = ITEM_SKIP_AMOUNT
        query.findObjectsInBackgroundWithBlock { (result:[PFObject]?, error:NSError?) -> Void in
            self.itemQueryCompletionHandler(result: result, error: error, removeAll: false)
            self.doneItemLoadingMoreTableViewData()
        }
    }
    
    func itemQueryCompletionHandler (result result:[PFObject]!, error: NSError!, removeAll:Bool) {
        if (error == nil) {
            if removeAll {
                givenItems.removeAll()
                ITEM_SKIP_AMOUNT = 0
            }
            itemCouldLoadMore = result.count >= ITEM_SINGLE_LOAD_AMOUNT
            ITEM_SKIP_AMOUNT += result.count
            print("Find \(result.count) items.")
            
            switch showCategory {
            case .ShowAll:
                for given in result! {
                    self.givenItems.append(given)
                }
            case .ShowShare:
                for given in result! {
                    let borrowUser = given[AppKeys.ItemRelationship.requester] as? PFUser == self.currentUser
                    let connected = given[AppKeys.ItemRelationship.connected] as! Bool
                    let lendUser = given[AppKeys.ItemRelationship.requestedLender] as? PFUser == self.currentUser
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
            case .ShowOwn:
                for given in result! {
                    let isOwner = given[AppKeys.ItemRelationship.owner] as? PFUser == self.currentUser
                    if isOwner {
                        self.givenItems.append(given)
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

    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
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
            let cell = tableView.dequeueReusableCellWithIdentifier(AppKeys.CellIdentifiers.loadingCell, forIndexPath: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .NoResults:
            let cell = tableView.dequeueReusableCellWithIdentifier(AppKeys.CellIdentifiers.noResultsCell, forIndexPath: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCellWithIdentifier(AppKeys.CellIdentifiers.listedCell, forIndexPath: indexPath) as! ListedCell
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
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return showCategory == .ShowOwn && givenItems.count > 0 ? true : false
    }
    
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == UITableViewCellEditingStyle.Delete {
            givenItems[indexPath.row].deleteInBackground()
            givenItems.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    // MARK: - segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == AppKeys.SegueIdentifiers.detailReveal {
            let selectedIndex = self.tableView.indexPathForCell(sender as! UITableViewCell)
            self.tableView.deselectRowAtIndexPath(self.tableView.indexPathForCell(sender as! UITableViewCell)!, animated: true)
            let controller = segue.destinationViewController as! DetailViewController
            controller.item = givenItems[(selectedIndex?.row)!]
        }
    }
    
    // MARK: - Pull to load more
    func loadMoreTableFooterDidTriggerRefresh(view: LoadMoreTableFooterView) {
        itemloadMoreTableViewDataSource()
    }
    
    func loadMoreTableFooterDataSourceIsLoading(view: LoadMoreTableFooterView) -> Bool {
        return itemIsLoadingMore
    }
    
    func itemloadMoreTableViewDataSource() {
        if itemIsLoadingMore {return}
        itemIsLoadingMore = true
        itemLoadMoreSelector()
    }
    
    func doneItemLoadingMoreTableViewData() {
        itemIsLoadingMore = false
        itemLoadMoreFooterView.loadMoreScrollViewDataSourceDidFinishedLoading()
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if (itemAllowLoadingMore && itemCouldLoadMore) {
            itemLoadMoreFooterView.loadMoreScrollViewDidScroll(scrollView)
        }
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (itemAllowLoadingMore && itemCouldLoadMore) {
            itemLoadMoreFooterView.loadMoreScrollViewDidEndDragging(scrollView)
        }
    }
}
