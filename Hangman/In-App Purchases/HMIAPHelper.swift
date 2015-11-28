//
//  HMIAPHelper.swift
//  Hangman
//
//  Created by phil on 02/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import Foundation

class HMIAPHelper: IAPHelper {
    
    static let sharedInstance = HMIAPHelper()
    
    override func provideContentWithURL(URL: NSURL) {
        HMContentController.sharedInstance.unlockContentWithDirURL(URL)
    }
    
    override func notifyStatusForProduct(product: IAPProduct, string: String) {
        guard let skProduct = product.skProduct else {
               print("skProduct nul")
            return
        }
        
        let message = "\(skProduct.localizedTitle): \(string)"
        let notify = PESmallNotifier(title: message)
        notify.showFor(2)

    }
}