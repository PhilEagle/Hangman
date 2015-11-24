//
//  HMStoreListViewController.swift
//  Hangman
//
//  Created by phil on 02/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
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
    
    private var products: [IAPProduct]? {
        willSet {
            self.removeObservers()
        }
        didSet {
            self.addObservers()
        }
    }
    
    private var observing: Bool = false

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
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addObservers()
        tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeObservers()
    }
    
    //MARK: - KVO
    private func addObservers() {
        if observing || products == nil { return }
        
        observing = true
        
        for product in products! {
            product.addObserver(self, forKeyPath: "purchaseInProgress", options: [], context: nil)
            product.addObserver(self, forKeyPath: "purchase", options: [], context: nil)
        }
    }
    
    private func removeObservers() {
        if !observing { return }
        
        observing = false

        for product in products! {
            product.removeObserver(self, forKeyPath: "purchaseInProgress")
            product.removeObserver(self, forKeyPath: "purchase")
        }
        
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let product = object as? IAPProduct else {
            return
        }
        
        let row = products?.indexOf(product)
        let indexPath = NSIndexPath(forRow: row!, inSection: 0)
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
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
        cell.iconImageView.image = UIImage(named: product.info!.icon)
        cell.titleLabel.text = product.skProduct!.localizedTitle
        cell.descriptionLabel.text = product.skProduct!.localizedDescription
        priceFormatter.locale = product.skProduct!.priceLocale
        
        if (product.purchase?.consumable != true && product.purchase != nil) {
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
            guard let strongSelf = self else {
                return
            }
            
            if success {
                strongSelf.products = products
                strongSelf.tableView.reloadData()
            }
            strongSelf.refreshControl?.endRefreshing()
        }
    }
    
    //MARK: - Interface
    func doneTapped(sender: UIBarButtonItem) {
    }
    
    func restoreTapped(sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "Restore Content", message: "Would you like to check for and restore any previous purchases?", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> () in
            HMIAPHelper.sharedInstance.restoreCompletedTransactions()
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
}