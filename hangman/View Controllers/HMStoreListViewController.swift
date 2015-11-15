//
//  HMStoreListViewController.swift
//  Hangman
//
//  Created by philippe eggel on 02/11/2015.
//  Copyright © 2015 Ray Wenderlich. All rights reserved.
//

import UIKit
import StoreKit

class HMStoreListViewController: UITableViewController {
    
    private let cellIdentifier = "Cell"
    private lazy var priceFormatter: NSNumberFormatter = {
        let priceFormatter = NSNumberFormatter()
        priceFormatter.formatterBehavior = .Behavior10_4
        priceFormatter.numberStyle = .CurrencyStyle
        return priceFormatter
    }()
    
    private var products: [IAPProduct]?

    override func viewDidLoad() {
        super.viewDidLoad()

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneTapped:")
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .Plain, target: self, action: "restoreTapped:")
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: "reload", forControlEvents: .ValueChanged)
        reload()
        refreshControl?.beginRefreshing()
    }

    //MARK: - UITableView datasource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! HMStoreListViewCell
        
        let product = products![indexPath.row]
        cell.titleLabel.text = product.skProduct!.localizedTitle
        cell.descriptionLabel.text = product.skProduct!.localizedDescription
        priceFormatter.locale = product.skProduct!.priceLocale
        
        if (product.purchase) {
            cell.priceLabel.text = "Installed"
        } else {
            cell.priceLabel.text = priceFormatter.stringFromNumber(product.skProduct!.price)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        performSegueWithIdentifier("PushDetail", sender: indexPath)
    }
    
    
    //MARK: Segues
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "PushDetail" {
            let detailViewController = segue.destinationViewController as! HMStoreDetailViewController
            let indexPath = sender as! NSIndexPath
            let product = products![indexPath.row]
            detailViewController.product = product
        }
    }
    
    
    func reload() {
        products = nil
        
        tableView.reloadData()
        
        HMIAPHelper.sharedInstance.requestProductsWithCompletionHandler { [weak self] (success, products) -> () in
            if self == nil {
                return
            }
            
            if success {
                self!.products = products
                self!.tableView.reloadData()
            }
            self!.refreshControl?.endRefreshing()
        }
    }
    
    
    //MARK: - Interface
    func doneTapped(sender: UIBarButtonItem) {
    }
    
    func restoreTapped(sender: UIBarButtonItem) {
    }
}
