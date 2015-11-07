//
//  IAPHelper.swift
//  Hangman
//
//  Created by philippe eggel on 02/11/2015.
//  Copyright © 2015 Ray Wenderlich. All rights reserved.
//

import Foundation
import StoreKit

typealias RequestProductsCompletionHandler = (Bool, [IAPProduct]?) -> ()

class IAHelper: NSObject {
    private var products: [String: IAPProduct]
    private var productsRequest: SKProductsRequest?
    private var completionHandler: RequestProductsCompletionHandler?
    
    init(products: [String: IAPProduct]) {
        self.products = products
        super.init()
    }
    
    // getting product identifier (using productsRequest callback)
    func requestProductsWithCompletionHandler(completion: RequestProductsCompletionHandler?) {
        
        //1 storing the completion block
        completionHandler = completion
        
        //2 Creating the pool of identifiers
        var productIdentifiers = Set<String>()
        for product in products.values {
            product.availableForPurchase = false
            productIdentifiers.insert(product.productIdentifier)
        }
        
        //3 Requesting in-app products
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
        
        //1 connect IAPProduct between apple and our app
        let skProducts = response.products
        for skProduct in skProducts {
            guard let product = products[skProduct.productIdentifier] else {
                continue
            }
            product.skProduct = skProduct
            product.availableForPurchase = true
        }
        
        //2 deactivate invalid products
        for invalidProductID in response.invalidProductIdentifiers {
            guard let product = products[invalidProductID] else {
                continue
            }
            product.availableForPurchase = false
            print("Invalid product ID, removing: \(invalidProductID)")
        }
        
        //3 store available products in an array
        var availableProducts = [IAPProduct]()
        for product in products.values {
            if product.availableForPurchase {
                availableProducts.append(product)
            }
        }
        
        //4 start completion closure
        if let completionHandler = completionHandler {
            completionHandler(true, availableProducts)
        }
        completionHandler = nil
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print("Failed to load list of products: \(error.localizedDescription)")
        
        productsRequest = nil
        
        //4 start completion closure
        if let completionHandler = completionHandler {
            completionHandler(false, nil)
        }
        completionHandler = nil
    }
}