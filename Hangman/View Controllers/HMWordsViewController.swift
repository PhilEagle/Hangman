//
//  HMWordsViewController.swift
//  Swift Hangman
//
//  Created by phil on 10/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import Foundation

extension HMWordsViewController {
    func registerNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unlockedWordsChanged:", name: HMContentControllerCurrentWordsDidChangeNotification, object: nil)
    }
}