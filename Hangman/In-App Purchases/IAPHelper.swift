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

struct IAPHelperConstant {
    static let IAPServerBaseURL = "http://www.phileagledev.com"
    static let IAPServerProductURL = "hangman/IAPInfo/productInfos.plist"
    static let IAPHelperPurchasePlist = "purchase.plist"
}

class IAPHelper: NSObject {
    var products: [String: IAPProduct]
    private var productsRequest: SKProductsRequest?
    private var completionHandler: RequestProductsCompletionHandler?
    
    // flags
    private var productsLoadedFlag = false
    
    override init() {
        print("IAHelper init")
        products = [:]
        
        super.init()
        
        //load current purchased in-app product
        loadPurchases()
        loadProductsWithCompletionHandler {(success, error) -> () in}
    }

    //MARK: - Helper Method
    private func libraryPath() -> NSURL {
        let libraryPaths = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)
        return libraryPaths[0]
    }
    
    private func purchasePath() -> String {
        return libraryPath().URLByAppendingPathComponent(IAPHelperConstant.IAPHelperPurchasePlist).absoluteString
    }
    
    private func addPurchase(purchase: IAPProductPurchase, forProductIdentifier productIdentifier: String) {
        let product = addProductForProductIdentifier(productIdentifier)
        product.purchase = purchase
    }
    
    private func purchaseForProductIdentifier(productIdentifier: String) -> IAPProductPurchase? {
        if let product = products[productIdentifier] {
            return product.purchase
        } else {
            return nil
        }
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
    
    //MARK: - In-App Purchase product management
    // load package
    func loadProductsWithCompletionHandler(completionHandler: (Bool, NSError?) -> ()) {
        
        // preparing products
        for product in products.values {
            product.info = nil
            product.availableForPurchase = false
        }
        
        // NSURL session configuration
        let sessionConfig = NSURLSessionConfiguration.ephemeralSessionConfiguration()
        let session = NSURLSession(configuration: sessionConfig)
        let baseURL = NSURL(string: IAPHelperConstant.IAPServerBaseURL)
        let productURL = NSURL(string: IAPHelperConstant.IAPServerProductURL, relativeToURL: baseURL!)
        
        session.dataTaskWithURL(productURL!, completionHandler: { [weak self] (data, response, error) -> Void in
            guard let strongSelf = self else {
                return
            }
            
            if error == nil {
                do {
                    let productsInfosArray = try NSPropertyListSerialization.propertyListWithData(data!, options: .Immutable, format: nil) as! [[String: AnyObject]]
                    for productInfosDict in productsInfosArray {
                        let info = IAPProductInfo(dict: productInfosDict)
                        strongSelf.addInfo(info, forProductIdentifier: info.productIdentifier)
                    }
                    
                    if !strongSelf.productsLoadedFlag {
                        strongSelf.productsLoadedFlag = true
                        SKPaymentQueue.defaultQueue().addTransactionObserver(strongSelf)
                    }
                    
                    completionHandler(true, nil)
                    
                } catch let error as NSError {
                    print("Parse \(productURL!.absoluteString) error: \(error.localizedDescription)")
                    completionHandler(false, error)
                }
                
            } else {
                print("Load \(productURL!.absoluteString) error: \(error?.localizedDescription)")
                completionHandler(false, error)
            }
        }).resume()
        
    }
    
    // getting product identifier (using productsRequest callback)
    func requestProductsWithCompletionHandler(completion: RequestProductsCompletionHandler?) {
        
        //1 storing the completion block
        completionHandler = completion
    
        //2 Creating the pool of identifiers
        loadProductsWithCompletionHandler { [weak self] (success, error) -> () in
            guard let strongSelf = self else {
                return
            }
            
            var productIdentifiers = Set<String>()
            for product in strongSelf.products.values {
                if product.info != nil {
                    product.availableForPurchase = false
                    productIdentifiers.insert(product.productIdentifier)
                }
            }
            
            //3 Requesting in-app products
            strongSelf.productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            strongSelf.productsRequest?.delegate = strongSelf
            strongSelf.productsRequest?.start()
        }
        
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
        print("validateReceiptForTransaction()...")
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
                    || (originalTransactionID != nil && originalTransactionID == transaction.originalTransaction?.transactionIdentifier)
                {
                    strongSelf.provideContentForTransaction(transaction, productIdentifier: transaction.payment.productIdentifier)
                }
            }
        }
    }
    
    // MARK: - Load/Save locally current purchased products
    private func loadPurchases() {
        print("loadPurchases()")
        
        guard let purchasesArray = NSKeyedUnarchiver.unarchiveObjectWithFile(purchasePath()) as? [IAPProductPurchase] else {
            return
        }
        
        for purchase in purchasesArray {
            if purchase.libraryRelativePath != nil {
                let localURL = libraryPath().URLByAppendingPathComponent(purchase.libraryRelativePath!, isDirectory: true)
                provideContentWithURL(localURL)
            }
            
            addPurchase(purchase, forProductIdentifier: purchase.productIdentifier)
            print("Loaded purchase for \(purchase.productIdentifier) \(purchase.contentVersion)")
        }
    }
    
    private func savePurchases() {
        var purchasesArray = [IAPProductPurchase]()
        for product in products.values {
            if product.purchase != nil {
                purchasesArray.append(product.purchase!)
            }
        }
        
        let success = NSKeyedArchiver.archiveRootObject(purchasesArray, toFile: purchasePath())
        
        if !success {
            print("Failed to save purchases to \(purchasePath())")
        }
    }
}

// MARK: - SKProductsRequest Delegate
extension IAPHelper: SKProductsRequestDelegate {
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
extension IAPHelper: SKPaymentTransactionObserver {
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
        print("completeTransaction... id:\(transaction.transactionIdentifier! ?? "") originalId:\(transaction.originalTransaction?.transactionIdentifier! ?? "") date:\(transaction.transactionDate! ?? "") originalDate:\(transaction.originalTransaction?.transactionDate! ?? "")")
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
        
        //creating or updating the IAPProductPurchase
        if let previousPurchase = purchaseForProductIdentifier(productIdentifier) {
            previousPurchase.timesPurchased++
        } else {
            let newPurchase = IAPProductPurchase(productIdentifier: productIdentifier, consumable: true, timesPurchased: 1, libraryRelativePath: "", contentVersion: "")
            addPurchase(newPurchase, forProductIdentifier: productIdentifier)
        }
        savePurchases()
    }
    
    func provideContentWithURL(URL: NSURL) { }
    
    func purchaseNonConsumableAtURL(nonLocalURL: NSURL, forProductIdentifier productIdentifier: String) {
        
        var exists = false
        var isDirectory: ObjCBool = false
        
        //creating a local directory URL
        let libraryRelativePath = nonLocalURL.lastPathComponent!
        let localURL = libraryPath().URLByAppendingPathComponent(libraryRelativePath, isDirectory: true)
        exists = NSFileManager.defaultManager().fileExistsAtPath(localURL.absoluteString, isDirectory: &isDirectory)
        
        if NSFileManager.defaultManager().fileExistsAtPath(nonLocalURL.absoluteString, isDirectory: &isDirectory) {
            print("iosWords non found")
        }
        
        print("\(localURL.absoluteString)")
        
        //deleting directory if it already exists
        if exists {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(localURL)
                print("Remove old directory at \(localURL)")
            } catch let error as NSError {
                print("Couldn't delete directory at \(localURL): \(error.localizedDescription)")
            }
        }
        
        //copying directory to the library location
        do {
            try NSFileManager.defaultManager().copyItemAtURL(nonLocalURL, toURL: localURL)
            print("Copying directory from \(nonLocalURL) to \(localURL)")
        } catch let error as NSError {
            print("Failed to copy directory \(error.localizedDescription)")
            nofityStatusForProductIdentifier(productIdentifier, string: "Copying failed.")
            return
        }
        
        //unlocking content
        provideContentWithURL(localURL)
        
        let contentVersion = ""
        if let previousPurchase = purchaseForProductIdentifier(productIdentifier) {
            //updating the purchase
            previousPurchase.timesPurchased++
            
            let oldURL = libraryPath().URLByAppendingPathComponent(previousPurchase.libraryRelativePath!)
            do {
                try NSFileManager.defaultManager().removeItemAtURL(oldURL)
                print("Remove old purchase at \(oldURL)")
            } catch let error as NSError {
                print("Could not remove the old purchase at \(oldURL): \(error.localizedDescription)")
            }
            
            previousPurchase.libraryRelativePath = libraryRelativePath
            previousPurchase.contentVersion = contentVersion
        } else {
            //creating the purchase
            let purchase = IAPProductPurchase(productIdentifier: productIdentifier, consumable: false, timesPurchased: 1, libraryRelativePath: libraryRelativePath, contentVersion: contentVersion)
            addPurchase(purchase, forProductIdentifier: productIdentifier)
        }
        
        nofityStatusForProductIdentifier(productIdentifier, string: "Purchase Complete!")
        
        savePurchases()
    }
    
    func nofityStatusForProductIdentifier(productIdentifier: String, string: String) {
        let product = products[productIdentifier]!
        notifyStatusForProduct(product, string: string)
        
    }
    
    // App-Dependant implementation
    func notifyStatusForProduct(product: IAPProduct, string: String) {}
}
