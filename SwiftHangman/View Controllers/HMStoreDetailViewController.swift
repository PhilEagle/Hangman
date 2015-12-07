//
//  HMStoreListViewControllerTableViewController.swift
//  Hangman
//
//  Created by Phil Eggel on 02/11/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
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
        product.addObserver(self, forKeyPath: "progress", options: [], context: nil)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        product.removeObserver(self, forKeyPath: "purchaseInProgress")
        product.removeObserver(self, forKeyPath: "purchase")
        product.removeObserver(self, forKeyPath: "progress")
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        refresh()
    }

    func refresh() {
        guard let skProduct = product.skProduct else {
            print("skProduct not initialized...")
            return
        }
        
        if skProduct.downloadable {
            let numBytes = skProduct.downloadContentLengths.first?.integerValue ?? 0
            let numBytesString = prettyBytes(numBytes)
            versionLabel.text = "Version \(skProduct.downloadContentVersion) (\(numBytesString))"
        } else {
            versionLabel.text = "Version 1.0"
        }
        
        title = skProduct.localizedTitle
        titleLabel.text = skProduct.localizedTitle
        descriptionTextView.text = skProduct.localizedDescription
        priceFormatter.locale = skProduct.priceLocale
        priceLabel.text = priceFormatter.stringFromNumber(skProduct.price)
        
        
        if product.allowedToPurchase() {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Buy", style: .Plain, target: self, action: "buyTapped:")
            navigationItem.rightBarButtonItem?.enabled = true
        } else {
            navigationItem.rightBarButtonItem = nil
        }
        
        pauseButton.hidden = true
        resumeButton.hidden = true
        cancelButton.hidden = true
        
        if product.purchaseInProgress {
            
            statusLabel.hidden = false
            progressView.hidden = false
            
            if let skDownload = product.skDownload {
                //Content provided from Apple Server
                pauseButton.hidden = false
                resumeButton.hidden = false
                cancelButton.hidden = false
            
                switch skDownload.downloadState {
                case .Active:
                    if skDownload.timeRemaining >= 0 {
                        statusLabel.text = String(format:"Active %0.2s remaining...", skDownload.timeRemaining)
                    } else {
                        statusLabel.text = "Active..."
                    }
                    
                case .Waiting:
                    if skDownload.timeRemaining >= 0 {
                        statusLabel.text = String(format:"Waiting %0.2s remaining...", skDownload.timeRemaining)
                    } else {
                        statusLabel.text = "Waiting..."
                    }
                
                case .Finished:
                    statusLabel.text = "Download finished."

                case .Failed:
                    statusLabel.text = "Download failed."
                    
                case .Paused:
                    statusLabel.text = "Download paused."
                    
                case .Cancelled:
                    statusLabel.text = "Download cancelled."
                    
                }
                
                progressView.progress = product.progress
            
            } else {
                //Installing content
                statusLabel.text = "Installing..."
                progressView.progress = product.progress
            }
            
        } else if let purchase = product.purchase {
            
            if !purchase.consumable {
            
                statusLabel.hidden = false
                progressView.hidden = true
            
                if !skProduct.downloadContentVersion.isEmpty && skProduct.downloadContentVersion != purchase.contentVersion {
                    statusLabel.text = "Update Available, Please Restore."
                } else {
                    statusLabel.text = "Installed."
                }
            
            } else {
                
                statusLabel.hidden = false
                progressView.hidden = true
                
                guard let info = product.info else {
                    fatalError("Unexpected info.")
                }
                
                let newValue = NSUserDefaults.standardUserDefaults().integerForKey(info.consumableIdentifier)
                statusLabel.text = "Current value: \(newValue)"
            
            }
            
        } else {
            
            statusLabel.hidden = true
            progressView.hidden = true
            
        }
        
    }
    
    // MARK: - CallBacks
    func buyTapped(sender: UIBarButtonItem) {
        print("Buy tapped !")
        HMIAPHelper.sharedInstance.buyProduct(product)
    }
    
    @IBAction func pauseTapped(sender: UIButton) {
        if let skDownload = product.skDownload {
            HMIAPHelper.sharedInstance.pauseDownloads([skDownload])
        }
    }
    
    @IBAction func resumeTapped(sender: UIButton) {
        if let skDownload = product.skDownload {
            HMIAPHelper.sharedInstance.resumeDownloads([skDownload])
        }
    }
    
    @IBAction func cancelTapped(sender: UIButton) {
        if let skDownload = product.skDownload {
            HMIAPHelper.sharedInstance.cancelDownloads([skDownload])
        }
    }

}
