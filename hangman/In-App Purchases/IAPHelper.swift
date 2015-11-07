//
//  IAPHelper.swift
//  Hangman
//
//  Created by philippe eggel on 02/11/2015.
//  Copyright © 2015 Ray Wenderlich. All rights reserved.
//

import Foundation
import StoreKit

class IAHelper: NSObject {
    var productsRequest: SKProductsRequest?
    
    // getting product identifier (using productsRequest callback)
    func requestProductsWithProductIdentifier(productIdentifiers: Set<String>) {
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
        productsRequest!.delegate = self
        productsRequest!.start()
    }
}

// MARK: - SKProductsRequest Delegate
extension IAHelper: SKProductsRequestDelegate {
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        print("Loaded list of products...")
        productsRequest = nil
        
        let skProducts = response.products
        
        for skProduct in skProducts {
            print("Found product: \(skProduct.productIdentifier) \(skProduct.localizedTitle) \(NSString(format: "%0.2f", skProduct.price.floatValue)))")
        }
        
        for invalidProduct in response.invalidProductIdentifiers {
            print("Found invalid product: \(invalidProduct)")
        }
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print("Failed to load list of products: \(error.localizedDescription)")
        productsRequest = nil
    }
}