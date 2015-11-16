//
//  HMStoreListViewControllerTableViewController.swift
//  Hangman
//
//  Created by phil on 02/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import UIKit
import StoreKit

class HMStoreDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    var product: IAPProduct!
    private lazy var priceFormatter: NSNumberFormatter = {
        let priceFormatter = NSNumberFormatter()
        priceFormatter.formatterBehavior = .Behavior10_4
        priceFormatter.numberStyle = .CurrencyStyle
        return priceFormatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage:UIImage(named: "bg.png")!)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        statusLabel.hidden = true
        refresh()
        
        product.addObserver(self, forKeyPath: "purchaseInProgress", options: [], context: nil)
        product.addObserver(self, forKeyPath: "purchase", options: [], context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        product.removeObserver(self, forKeyPath: "purchaseInProgress")
        product.removeObserver(self, forKeyPath: "purchase")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        refresh()
    }

    func refresh() {
        title = product.skProduct!.localizedTitle
        
        titleLabel.text = product.skProduct!.localizedTitle
        descriptionTextView.text = product.skProduct!.localizedDescription
        priceFormatter.locale = product.skProduct!.priceLocale
        priceLabel.text = priceFormatter.stringFromNumber(product.skProduct!.price)
        versionLabel.text = "Version 1.0"
        
        if product.allowedToPurchase() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Buy", style: .Plain, target: self, action: "buyTapped:")
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        pauseButton.hidden = true
        resumeButton.hidden = true
        cancelButton.hidden = true
        
    }
    
    // MARK: - CallBacks
    func buyTapped(sender: UIBarButtonItem) {
        print("Buy tapped !")
        HMIAPHelper.sharedInstance.buyProduct(product)
    }
    
    @IBAction func pauseTapped(sender: UIButton) {
    }
    
    @IBAction func resumeTapped(sender: UIButton) {
    }
    
    @IBAction func cancelTapped(sender: UIButton) {
    }

}
