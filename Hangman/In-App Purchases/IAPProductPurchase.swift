//
//  IAPProductPurchase.swift
//  Swift Hangman
//
//  Created by Phil on 23/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

struct ProductPurchaseKey {
    static let ProductIdentifier = "ProductIdentifier"
    static let Consumable = "Consumable"
    static let TimesPurchased = "TimesPurchased"
    static let LibraryRelativePath = "LibraryRelativePath"
    static let ContentVersion = "ContentVersion"
}

class IAPProductPurchase: NSObject, NSCoding {

    var productIdentifier: String
    var consumable: Bool
    var timesPurchased: Int32
    var libraryRelativePath: String?
    var contentVersion: String
    
    init(productIdentifier: String, consumable: Bool, timesPurchased: Int32, libraryRelativePath: String?, contentVersion: String) {
        self.productIdentifier = productIdentifier
        self.consumable = consumable
        self.timesPurchased = timesPurchased
        self.libraryRelativePath = libraryRelativePath
        self.contentVersion = contentVersion
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let productIdentifier = aDecoder.decodeObjectForKey(ProductPurchaseKey.ProductIdentifier) as? String
        let consumable = aDecoder.decodeBoolForKey(ProductPurchaseKey.Consumable)
        let timesPurchased = aDecoder.decodeIntForKey(ProductPurchaseKey.TimesPurchased)
        let libraryRelativePath = aDecoder.decodeObjectForKey(ProductPurchaseKey.LibraryRelativePath) as? String
        let contentVersion = aDecoder.decodeObjectForKey(ProductPurchaseKey.ContentVersion) as? String
        
        if (productIdentifier == nil || contentVersion == nil) {
            return nil
        }
        
        self.init(productIdentifier: productIdentifier!, consumable: consumable, timesPurchased: timesPurchased, libraryRelativePath: libraryRelativePath, contentVersion: contentVersion!)
    }
    
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(productIdentifier, forKey: ProductPurchaseKey.ProductIdentifier)
        aCoder.encodeBool(consumable, forKey: ProductPurchaseKey.Consumable)
        aCoder.encodeInt(timesPurchased, forKey: ProductPurchaseKey.TimesPurchased)
        aCoder.encodeObject(libraryRelativePath, forKey: ProductPurchaseKey.LibraryRelativePath)
        aCoder.encodeObject(contentVersion, forKey: ProductPurchaseKey.ContentVersion)
    }

}
