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

    
    //MARK: - Helper Methods
    private func libraryPath() -> NSURL {
        let libraryPaths = NSFileManager.defaultManager().URLsForDirectory(.LibraryDirectory, inDomains: .UserDomainMask)
        return libraryPaths[0]
    }
    
    private func purchasePath() -> String {
        return libraryPath().URLByAppendingPathComponent(IAPHelperConstant.IAPHelperPurchasePlist).path!
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
                    print("Parse \(productURL!.path!) error: \(error.localizedDescription)")
                    completionHandler(false, error)
                }
                
            } else {
                print("Load \(productURL!.path!) error: \(error?.localizedDescription)")
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
    
    
    //MARK: - Load/Save locally current purchased products
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
        
        print("path: \(purchasePath())")
        let success = NSKeyedArchiver.archiveRootObject(purchasesArray, toFile: purchasePath())

        if !success {
            print("Failed to save purchases to \(purchasePath())")
        }
    }
    
    
    //MARK: - Manage SKDownload
    func pauseDownloads(downloads: [SKDownload]) {
        SKPaymentQueue.defaultQueue().pauseDownloads(downloads)
    }
    
    func resumeDownloads(downloads: [SKDownload]) {
        SKPaymentQueue.defaultQueue().resumeDownloads(downloads)
    }
    
    func cancelDownloads(downloads: [SKDownload]) {
        SKPaymentQueue.defaultQueue().cancelDownloads(downloads)
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
    
    func paymentQueue(queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        //1 pull out bunch of infos
        guard let download = downloads.first else {
            print("Unabled to recover download!")
            return
        }
        let transaction = download.transaction
        let payment = transaction.payment
        let productIdentifier = payment.productIdentifier
        guard let product = products[productIdentifier] else {
            print("Unabled to recover product \(productIdentifier)")
            return
        }
        
        //2 start track progress
        product.progress = download.progress
        
        //3 use downloadState
        print("Download state: \(download.downloadState)")
        switch download.downloadState {
        case .Finished:
            guard let contentURL = download.contentURL else {
                print("Unabled to recover local location.")
                return
            }
            purchaseNonConsumableAtURL(contentURL, forProductIdentifier: productIdentifier)
            product.purchaseInProgress = false
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        
        case .Failed:
            print("Download failed.")
            nofityStatusForProductIdentifier(productIdentifier, string: "Download failed.")
            product.purchaseInProgress = false
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        
        case .Cancelled:
            print("Download cancelled.")
            nofityStatusForProductIdentifier(productIdentifier, string: "Download cancelled.")
            product.purchaseInProgress = false
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        
        default:
            print("Download for \(productIdentifier): \(String(format: "%0.2f", product.progress)) complete")
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
        guard let product = products[productIdentifier] else {
            print("Unabled to recover this product!")
            return
        }
        
        let downloads = transaction.downloads
        if !downloads.isEmpty {
            //download remote package from apple server
            product.skDownload = downloads.first
            if downloads.count > 1 {
                //should be only one package
                print("Unexpected number of downloads!")
            }
            SKPaymentQueue.defaultQueue().startDownloads(downloads)
        } else {
            //no remote package provided
            provideContentForProductIdentifier(productIdentifier, notify: true)
            SKPaymentQueue.defaultQueue().finishTransaction(transaction)
        }
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
        
        var isDirectory: ObjCBool = false
        
        //creating a local directory URL
        //Relative Path
        var libraryRelativePath = nonLocalURL.lastPathComponent!
        
        //Local URL: library + relative
        var localURL = libraryPath().URLByAppendingPathComponent(libraryRelativePath, isDirectory: true)

        //check oif nonLocalURL exist
        if !NSFileManager.defaultManager().fileExistsAtPath(nonLocalURL.path!, isDirectory: &isDirectory) {
            print("Directory doesn't exist at \(nonLocalURL.path!). Unabled to continue.")
            nofityStatusForProductIdentifier(productIdentifier, string: "Copying failed.")
            return
        }
        
        //deleting directory if it already exists
        if NSFileManager.defaultManager().fileExistsAtPath(localURL.path!, isDirectory: &isDirectory) {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(localURL)
            } catch let error as NSError {
                print("Unabled to delete directory at \(localURL): \(error.localizedDescription)")
            }
        }
        
        //copying directory to the library location
        do {
            try NSFileManager.defaultManager().copyItemAtURL(nonLocalURL, toURL: localURL)
        } catch let error as NSError {
            print("Failed to copy directory \(error.localizedDescription)")
            nofityStatusForProductIdentifier(productIdentifier, string: "Copying failed.")
            return
        }
        
        
        //check if contents was remotely downloaded from Apple Server (ContentInfo.plist)
        var contentVersion = ""
        let contentInfoURL = localURL.URLByAppendingPathComponent("ContentInfo.plist")
        
        if NSFileManager.defaultManager().fileExistsAtPath(contentInfoURL.path!, isDirectory: &isDirectory) {
            guard let info = NSDictionary(contentsOfURL: contentInfoURL), version = info["ContentVersion"] as? String else {
                print("Failed to recover ContentInfo.plist")
                nofityStatusForProductIdentifier(productIdentifier, string: "Recover remote infos failed.")
                return
            }
            
            contentVersion = version
            let contentPath = NSString(string: libraryRelativePath).stringByAppendingPathComponent("Contents") as String
            let fullContentsURL = libraryPath().URLByAppendingPathComponent(contentPath)
            
            if NSFileManager.defaultManager().fileExistsAtPath(fullContentsURL.path!) {
                libraryRelativePath = contentPath
                localURL = libraryPath().URLByAppendingPathComponent(libraryRelativePath, isDirectory: true)
            }
        }
        
        
        //unlocking content
        provideContentWithURL(localURL)
        
        
        if let previousPurchase = purchaseForProductIdentifier(productIdentifier) {
            //updating the purchase
            previousPurchase.timesPurchased++
            
            let oldURL = libraryPath().URLByAppendingPathComponent(previousPurchase.libraryRelativePath!)
            do {
                try NSFileManager.defaultManager().removeItemAtURL(oldURL)
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
