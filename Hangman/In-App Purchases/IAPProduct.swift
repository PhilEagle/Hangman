//
//  IAAProduct.swift
//  Swift Hangman
//
//  Created by phil on 07/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import Foundation
import StoreKit

class IAPProduct: NSObject {
    
    var availableForPurchase: Bool
    var productIdentifier: String
    var info: IAPProductInfo?
    var skProduct: SKProduct?
    
    //properties to manage download content from apple
    var progress: Float = 0.0
    var skDownload: SKDownload?
    
    dynamic var purchaseInProgress: Bool        // toggle KVO with dynamic keyword
    dynamic var purchase: IAPProductPurchase?   // toggle KVO with dynamic keyword
    
    required init(productIdentifier: String) {
        self.availableForPurchase = false
        self.productIdentifier = productIdentifier
        self.skProduct = nil
        self.purchaseInProgress = false
        
        super.init()
    }
    
    func allowedToPurchase() -> Bool {
        // Available For Purchasing ?
        if !availableForPurchase {
            return false
        }
        
        // Purchase in progress
        if purchaseInProgress {
            return false
        }
        
        // No information about the product
        if info == nil {
            return false
        }
        
        // Product is not a consumable and purchase is created
        if info?.consumable != true && purchase != nil {
            return false
        }
        
        return true
    }
}