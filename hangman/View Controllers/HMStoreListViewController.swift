//
//  HMStoreListViewController.swift
//  Hangman
//
//  Created by philippe eggel on 02/11/2015.
//  Copyright © 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class HMStoreListViewController: UITableViewController {
    
    private let cellIdentifier = "Cell"

    override func viewDidLoad() {
        super.viewDidLoad()

        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Done", style: .Plain, target: self, action: "doneTapped:")
        }
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Restore", style: .Plain, target: self, action: "restoreTapped:")
    }

    //MARK: - UITableView datasource
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as! HMStoreListViewCell
        return cell
    }
    
    //MARK: - Interface
    func doneTapped(sender: UIBarButtonItem) {
    }
    
    func restoreTapped(sender: UIBarButtonItem) {
        // Testing purposes only
        performSegueWithIdentifier("PushDetail", sender: nil)
    }
}
