//
//  HMIAPHelper.swift
//  Hangman
//
//  Created by philippe eggel on 02/11/2015.
//  Copyright © 2015 Ray Wenderlich. All rights reserved.
//

import Foundation

class HMIAPHelper: IAHelper {
    
    static let sharedInstance = HMIAPHelper()
    
    func requestProducts() {
        var productsIDs = Set<String>()
        productsIDs.insert("com.phileagledev.swifthangman.tenhints")
        productsIDs.insert("com.phileagledev.swifthangman.hundredhints")
        
        return super.requestProductsWithProductIdentifier(productsIDs)
    }
}