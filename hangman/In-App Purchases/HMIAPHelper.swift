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
    
    init() {
        let tenHints = IAPProduct(productIdentifier: "com.phileagledev.swifthangman.tenhints")
        let hundredHints = IAPProduct(productIdentifier: "com.phileagledev.swifthangman.hundredhints")
        let products = [tenHints.productIdentifier: tenHints, hundredHints.productIdentifier: hundredHints]
        
        super.init(products: products)
    }
}