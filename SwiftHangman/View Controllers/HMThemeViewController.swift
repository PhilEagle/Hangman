//
//  HMThemeViewController.swift
//  Swift Hangman
//
//  Created by Phil Eggel on 10/11/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import Foundation

extension HMThemeViewController {
    func registerNotification() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "unlockedThemesChanged:", name: HMContentControllerCurrentThemeDidChangeNotification, object: nil)
    }
}