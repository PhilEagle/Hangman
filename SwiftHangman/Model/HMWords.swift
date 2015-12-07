//
//  HMWords.swift
//  Hangman
//
//  Created by Phil Eggel on 02/11/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import Foundation

class HMWords: NSObject {
    private(set) var dirURL: NSURL
    private(set) var name: String
    private var words: [String]
    
    static func wordsAtURL(url: NSURL) -> Bool {
        let plistURL = url.URLByAppendingPathComponent("words.plist")
        return NSFileManager.defaultManager().fileExistsAtPath(plistURL.path!)
    }
    
    init(dirURL: NSURL) {
        let plistURL = dirURL.URLByAppendingPathComponent("words.plist")
        guard let dict = NSDictionary(contentsOfURL: plistURL) else {
            fatalError("dictionary not found")
        }

        self.dirURL = dirURL
        self.name = dict["name"] as! String
        self.words = dict["words"] as! [String]
        
        super.init()
    }
    
    func count() -> Int {
        return words.count
    }
    
    func objectAtIndexedSubscript(idx: Int) -> String {
        return words[idx]
    }
}