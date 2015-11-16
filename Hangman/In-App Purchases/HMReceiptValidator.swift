//
//  HMReceiptValidator.swift
//  Swift Hangman
//
//  Created by phil on 16/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import Foundation
import StoreKit

typealias ReceiptValidateBlock = ([[String: AnyObject]]?) -> ()

class HMReceiptValidator: NSObject {
    
    private var numAttempts = 0
    private var request: SKRequest?
    private var completionHandler: ReceiptValidateBlock?
    
    static let sharedInstance = HMReceiptValidator()
    
    func validateReceiptWithCompletionHandler(completionHandler: ReceiptValidateBlock?) {
        self.completionHandler = completionHandler
        validateReceipt()
    }
    
    private func validateReceipt() {
        numAttempts++
        print("validating receipt, attempts \(numAttempts)...")
        
        let receiptURL = NSBundle.mainBundle().appStoreReceiptURL
        let receiptPath = receiptURL?.path
        
        let validationSuccess = verifyReceiptAtPath(receiptPath)
        if validationSuccess {
            receiptDataValidate(receiptPath!)
        } else if numAttempts == 1 {
            print("Receipt failed to validate a first time, refreshing.")
            request = SKReceiptRefreshRequest()
            request?.delegate = self
            request?.start()
        } else {
            print("Receipt failed to validate a second time, continuing anyway...")
            //in a paid app use errorcode 173 to indicate a receipt validation error
            //or disable all paid in-app purchased
        }
    }
    
    private func receiptDataValidate(receiptPath: String) {
        print("Receipt validated!")
        let inAppPurchases = obtainInAppPurchases(receiptPath) as? [[String: AnyObject]]
        print("In App Purchases: \(inAppPurchases)")
        completionHandler?(inAppPurchases)
    }
}

extension HMReceiptValidator: SKRequestDelegate {
    func requestDidFinish(request: SKRequest) {
        print("Receipt refresh did finish...")
        self.request = nil
        validateReceipt()
    }
    
    func request(request: SKRequest, didFailWithError error: NSError) {
        print("Receipt failed to refresh, continuing anyway... Error: \(error.localizedDescription)")
        //in a paid app use errorcode 173 to indicate a receipt validation error
        //or disable all paid in-app purchased
        self.request = nil
        self.completionHandler?(nil)
    }
}