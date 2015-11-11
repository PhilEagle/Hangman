//
//  IAAProduct.swift
//  Swift Hangman
//
//  Created by philippe eggel on 07/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import Foundation
import StoreKit

class IAPProduct: NSObject {
    
    var availableForPurchase: Bool
    var productIdentifier: String
    var skProduct: SKProduct?
    var purchaseInProgress: Bool
    var purchase: Bool
    
    required init(productIdentifier: String) {
        self.availableForPurchase = false
        self.productIdentifier = productIdentifier
        self.skProduct = nil
        self.purchaseInProgress = false
        self.purchase = false
        
        super.init()
    }
    
    func allowedToPurchase() -> Bool {
        if !availableForPurchase {
            return false
        }
        
        if purchaseInProgress {
            return false
        }
        
        if purchase {
            return false
        }
        
        return true
    }
}