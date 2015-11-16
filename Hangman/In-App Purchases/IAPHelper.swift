//
//  IAPHelper.swift
//  Hangman
//
//  Created by phil on 02/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import Foundation
import StoreKit

typealias RequestProductsCompletionHandler = (Bool, [IAPProduct]?) -> ()

class IAHelper: NSObject {
    var products: [String: IAPProduct]
    private var productsRequest: SKProductsRequest?
    private var completionHandler: RequestProductsCompletionHandler?
    
    override init() {
        products = [:]
        
        super.init()
        
        //create current available products from productInfos files
        let productInfosURL = NSBundle.mainBundle().URLForResource("productInfos", withExtension: "plist")
        let productInfosArray = NSArray(contentsOfURL: productInfosURL!)
        for productInfos in productInfosArray! {
            guard let productDict = productInfos as? [String: AnyObject] else {
                continue
            }
            
            let info = IAPProductInfo(dict: productDict)
            addInfo(info, forProductIdentifier: info.productIdentifier)
        }
        
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }

    private func addInfo(info: IAPProductInfo, forProductIdentifier productIdentifier: String) {
        let product = addProductForProductIdentifier(productIdentifier)
        product.info = info
    }
    
    private func addProductForProductIdentifier(productIdentifier: String) -> IAPProduct {
        var product = products[productIdentifier]
        if product == nil {
            product = IAPProduct(productIdentifier: productIdentifier)
            products[productIdentifier] = product
        }
        
        return product!
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
    
    // Request: buy product on AppleStore
    func buyProduct(product: IAPProduct) {
        assert(product.allowedToPurchase(), "This product isn't allowed to be purchased")
        
        product.purchaseInProgress = true
        
        let payment = SKPayment(product: product.skProduct!)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    // Request: Restore completed transactions
    func restoreCompletedTransactions() {
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
    }
    
    // Request: Validate Receipt after a transaction
    func validateReceiptForTransaction(transaction: SKPaymentTransaction) {
        HMReceiptValidator.sharedInstance.validateReceiptWithCompletionHandler { [weak self] (inAppPurchases) -> () in
            guard let strongSelf = self else {
                return
            }
            
            guard let inAppPurchases = inAppPurchases else {
                print("inAppPurchases not a dictionary")
                return
            }
            
            for purchase in inAppPurchases {
                let transactionID = purchase["TransactionIdentifier"] as? String
                let originalTransactionID = purchase["OriginalTransactionIdentifier"] as? String
                
                if transactionID == transaction.transactionIdentifier
                    || originalTransactionID == transaction.originalTransaction
                {
                    strongSelf.provideContentForTransaction(transaction, productIdentifier: transaction.payment.productIdentifier)
                }
            }
        }
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


// MARK: - SKPaymentTransactionObserver
extension IAHelper: SKPaymentTransactionObserver {
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .Purchased:
                completeTransaction(transaction)
            case .Failed:
                failedTransaction(transaction)
            case .Restored:
                restoreTransaction(transaction)
            case .Deferred:
                print("transaction \(transaction.payment.productIdentifier) is Deferred")
            // case .Deferred is not used in this app (iOS 8). This state is used for familly sharing.
            default:
                break
            }
        }
    }
    
    private func completeTransaction(transaction: SKPaymentTransaction) {
        print("completeTransaction...")
        validateReceiptForTransaction(transaction)
    }
    
    private func restoreTransaction(transaction: SKPaymentTransaction) {
        print("restoreTransaction...")
        validateReceiptForTransaction(transaction)
    }
    
    private func failedTransaction(transaction: SKPaymentTransaction) {
        print("failedTransaction...")
        
        if transaction.error?.code != SKErrorPaymentCancelled {
            print("Transaction Error: \(transaction.error?.localizedDescription)")
        }
        
        let product = products[transaction.payment.productIdentifier]!
        
        nofityStatusForProductIdentifier(transaction.payment.productIdentifier, string: "Purchase failed")
        product.purchaseInProgress = false
        
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    private func provideContentForTransaction(transaction: SKPaymentTransaction, productIdentifier: String) {
        provideContentForProductIdentifier(productIdentifier, notify: true)
        SKPaymentQueue.defaultQueue().finishTransaction(transaction)
    }
    
    func provideContentForProductIdentifier(productIdentifier: String, notify: Bool) {
        guard let product = products[productIdentifier], info = product.info else {
            print("Product recovery error, or info not provided")
            return
        }
        
        if info.consumable {
            purchaseConsumable(info.consumableIdentifier,
                forProductIdentifier: productIdentifier,
                amount: info.consumableAmount)
        } else if !info.bundleDir.isEmpty {
            let bundleURL = NSBundle.mainBundle().resourceURL?.URLByAppendingPathComponent(info.bundleDir)
            purchaseNonConsumableAtURL(bundleURL!, forProductIdentifier: productIdentifier)
        }
        
        if notify {
            nofityStatusForProductIdentifier(productIdentifier, string: "Purchase complete!")
        }
        
        product.purchaseInProgress = false
    }
    
    func purchaseConsumable(consumableIdentifier: String, forProductIdentifier productIdentifier: String, amount consumableAmount: Int) {
        
        let previousAmount = NSUserDefaults.standardUserDefaults().integerForKey(consumableIdentifier)
        let newAmount = previousAmount + consumableAmount
        NSUserDefaults.standardUserDefaults().setInteger(newAmount, forKey: consumableIdentifier)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func provideContentWithURL(URL: NSURL) { }
    
    func purchaseNonConsumableAtURL(nonLocalURL: NSURL, forProductIdentifier productIdentifier: String) {
        provideContentWithURL(nonLocalURL)
    }
    
    func nofityStatusForProductIdentifier(productIdentifier: String, string: String) {
        let product = products[productIdentifier]!
        notifyStatusForProduct(product, string: string)
        
    }
    
    // App-Dependant implementation
    func notifyStatusForProduct(product: IAPProduct, string: String) {}
    
}
