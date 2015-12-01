//
//  HMMusicInfo.swift
//  Swift Hangman
//
//  Created by philippe eggel on 01/12/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import Foundation

class HMMusicInfo {
    
    var trackId: Int
    var trackName: String
    var artistName: String
    var price: Float
    var artworkURL: String
    
    init(trackId: Int, trackName: String, artistName: String, price: Float, artworkURL: String) {
        self.trackId = trackId
        self.trackName = trackName
        self.artistName = artistName
        self.price = price
        self.artworkURL = artworkURL
    }
    
}