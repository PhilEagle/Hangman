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
    
    override func provideContentForProductIdentifier(productIdentifier: String) {
        if productIdentifier == "com.phileagle.swifthangman.tenhints" {
            let curHints = HMContentController.sharedInstance.hints
            HMContentController.sharedInstance.hints = curHints + 10
        }
        else if productIdentifier == "com.phileagledev.swifthangman.hundredhints" {
            let curHints = HMContentController.sharedInstance.hints
            HMContentController.sharedInstance.hints = curHints + 100
        }
    }
    
    override func notifyStatusForProduct(product: IAPProduct, string: String) {
        guard let skProduct = product.skProduct else {
               print("skProudct nul")
            return
        }
        
        let message = "\(skProduct.localizedTitle): string"
        let notify = PESmallNotifier(title: message)
        notify.showFor(2)

    }
}