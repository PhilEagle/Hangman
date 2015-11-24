//
//  IAPProductInfo.swift
//  Swift Hangman
//
//  Created by Phil on 16/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import Foundation

class IAPProductInfo: NSObject {
    
    var productIdentifier: String
    var icon: String
    var consumable: Bool
    var consumableIdentifier: String
    var consumableAmount: Int
    var bundleDir: String
    
    init(dict: [String: AnyObject]) {
        self.productIdentifier = dict["productIdentifier"] as? String ?? ""
        self.icon = dict["icon"] as? String ?? ""
        self.consumable = dict["consumable"] as? Bool ?? false
        self.consumableIdentifier = dict["consumableIdentifier"] as? String ?? ""
        self.consumableAmount = dict["consumableAmount"] as? Int ?? 0
        self.bundleDir = dict["bundleDir"] as? String ?? ""
    }

}