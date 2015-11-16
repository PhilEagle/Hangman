//
//  HMViewController.swift
//  Swift Hangman
//
//  Created by phil on 10/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import Foundation

extension HMViewController {
    func registerNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentThemeChanged:", name: HMContentControllerCurrentThemeDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "currentWordsChanged:", name: HMContentControllerCurrentWordsDidChangeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "hintsChanged:", name: HMContentControllerHintsDidChangeNotification, object: nil)
    }
}