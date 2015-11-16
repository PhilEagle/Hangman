//
//  HMIAPHelper.swift
//  Hangman
//
//  Created by phil on 02/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import Foundation

class HMIAPHelper: IAHelper {
    
    static let sharedInstance = HMIAPHelper()
    
    init() {
        let tenHints = IAPProduct(productIdentifier: "com.phileagledev.swifthangman.tenhints")
        let hundredHints = IAPProduct(productIdentifier: "com.phileagledev.swifthangman.hundredhints")
        let hardWords = IAPProduct(productIdentifier: "com.phileagledev.swifthangman.hardwords")
        let iosWords = IAPProduct(productIdentifier: "com.phileagledev.swifthangman.ioswords")
        let products = [
            tenHints.productIdentifier: tenHints,
            hundredHints.productIdentifier: hundredHints,
            hardWords.productIdentifier: hardWords,
            iosWords.productIdentifier: iosWords
        ]
        
        super.init(products: products)
        
        /*
        if NSUserDefaults.standardUserDefaults().boolForKey("com.phileagledev.swifthangman.hardwords") {
            unlockWordsForProductIdentifier("com.phileagledev.swifthangman.hardwords", directory: "HardWords")
        }
        
        if NSUserDefaults.standardUserDefaults().boolForKey("com.phileagledev.swifthangman.ioswords") {
            unlockWordsForProductIdentifier("com.phileagledev.swifthangman.ioswords", directory: "iOSWords")
        }
        */
        
    }
    
    override func provideContentForProductIdentifier(productIdentifier: String) {
        if productIdentifier == "com.phileagle.swifthangman.tenhints" {
            let curHints = HMContentController.sharedInstance.hints
            HMContentController.sharedInstance.hints = curHints + 10
        }
        else if productIdentifier == "com.phileagledev.swifthangman.hundredhints" {
            let curHints = HMContentController.sharedInstance.hints
            HMContentController.sharedInstance.hints = curHints + 100
        }
        else if productIdentifier == "com.phileagledev.swifthangman.hardwords" {
            unlockWordsForProductIdentifier(productIdentifier, directory: "HardWords")
        }
        else if productIdentifier == "com.phileagledev.swifthangman.ioswords" {
            unlockWordsForProductIdentifier(productIdentifier, directory: "iOSWords")
        }
    }
    
    override func notifyStatusForProduct(product: IAPProduct, string: String) {
        guard let skProduct = product.skProduct else {
               print("skProduct nul")
            return
        }
        
        let message = "\(skProduct.localizedTitle): \(string)"
        let notify = PESmallNotifier(title: message)
        notify.showFor(2)

    }
    
    func unlockWordsForProductIdentifier(productIdentifier: String, directory: String) {
        let product = products[productIdentifier]
        product!.purchase = true
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: productIdentifier)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        let ressourceURL = NSBundle.mainBundle().resourceURL!
        
        HMContentController.sharedInstance.unlockContentWithDirURL(ressourceURL.URLByAppendingPathComponent(directory))
    }
}