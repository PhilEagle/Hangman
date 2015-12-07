//
//  HMContentController.swift
//  Swift Hangman
//
//  Created by Phil Eggel on 10/11/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import Foundation

let HMContentControllerCurrentThemeDidChangeNotification = "HMContentControllerCurrentThemeDidChangeNotification"
let HMContentControllerCurrentWordsDidChangeNotification = "HMContentControllerCurrentWordsDidChangeNotification"
let HMContentControllerHintsDidChangeNotification = "HMContentControllerHintsDidChangeNotification"
let HMContentControllerUnlockedThemesDidChangeNotification = "HMContentControllerUnlockedThemesDidChangeNotification"
let HMContentControllerUnlockedWordsDidChangeNotification = "HMContentControllerUnlockedWordsDidChangeNotification"

class HMContentController: NSObject {
    
    private(set) var unlockedThemes: [HMTheme]
    private(set) var unlockedWords: [HMWords]
    
    static let sharedInstance = HMContentController()
    
    var currentTheme: HMTheme? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(HMContentControllerCurrentThemeDidChangeNotification, object: nil)
        }
    }
    var currentWords: HMWords? {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(HMContentControllerCurrentWordsDidChangeNotification, object: nil)
        }
    }
    
    var hints: NSInteger {
        set {
            NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "com.phileagle.swifthangman.hints")
            NSUserDefaults.standardUserDefaults().synchronize()
            NSNotificationCenter.defaultCenter().postNotificationName(HMContentControllerHintsDidChangeNotification, object: nil)
        }
        get {
            return NSUserDefaults.standardUserDefaults().integerForKey("com.phileagle.swifthangman.hints")
        }
    }
    
    override init() {
        self.unlockedThemes = []
        self.unlockedWords = []
        
        super.init()
        
        guard let resourceURL = NSBundle.mainBundle().resourceURL else {
            fatalError("Resource folder unavailable")
        }
        
        // Theme and Words Pack base install
        unlockThemeWithDirURL(resourceURL.URLByAppendingPathComponent("Stickman"))
        unlockWordsWithDirURL(resourceURL.URLByAppendingPathComponent("EasyWords"))
        
        //unlockThemeWithDirURL(resourceURL.URLByAppendingPathComponent("robot"))
        //unlockThemeWithDirURL(resourceURL.URLByAppendingPathComponent("zombie"))

        
        let hasRunBefore = NSUserDefaults.standardUserDefaults().boolForKey("hasRunBefore")
        if !hasRunBefore {
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "hasRunBefore")
            NSUserDefaults.standardUserDefaults().synchronize()
            hints = 20
        }
        
    }
    
    func unlockThemeWithDirURL(dirURL: NSURL) {
        let theme = HMTheme(dirURL: dirURL)
        
        // Make sure we don't already have theme
        var found = false
        for var i = 0 ; i < unlockedThemes.count ; ++i {
            let curTheme = unlockedThemes[i]
            if theme.name == curTheme.name {
                print("Theme already unlocked, replacing...")
                if currentTheme == curTheme {
                    currentTheme = theme
                }
                
                unlockedThemes[i] = theme
                found = true
                break
            }
        }
    
        if !found {
            // Unlock new theme
            unlockedThemes.append(theme)
        }
        if (currentTheme == nil) {
            currentTheme = theme;
        }
    
        // Notify observers
        NSNotificationCenter.defaultCenter().postNotificationName(HMContentControllerUnlockedThemesDidChangeNotification, object: self)
    }
    
    func unlockWordsWithDirURL(dirURL: NSURL) {
        let words = HMWords(dirURL: dirURL)
        
        // Make sure we don't already have theme
        var found = false
        for var i = 0 ; i < unlockedWords.count ; ++i {
            let curWords = unlockedWords[i]
            if words.name == curWords.name {
                print("Words already unlocked, replacing...")
                if currentWords == curWords {
                    currentWords = words
                }
                
                unlockedWords[i] = words
                found = true
                break
            }
        }
        
        if !found {
            // Unlock new theme
            unlockedWords.append(words)
        }
        if (currentWords == nil) {
            currentWords = words;
        }
        
        // Notify observers
        NSNotificationCenter.defaultCenter().postNotificationName(HMContentControllerUnlockedWordsDidChangeNotification, object: self)
    }
    
    func unlockContentWithDirURL(dirURL: NSURL) {
    
        if HMTheme.themeAtURL(dirURL) {
            unlockThemeWithDirURL(dirURL)
        }
        else if HMWords.wordsAtURL(dirURL) {
            unlockWordsWithDirURL(dirURL)
        }
        else {
            print("Unexpected content!")
        }
    
    }
    
}