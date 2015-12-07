//
//  HMSettingsViewController.swift
//  Swift Hangman
//
//  Created by Phil Eggel on 08/11/2015.
//  Copyright © 2015 PhilEagleDev.com. All rights reserved.
//

import UIKit

class HMSettingsViewController: UITableViewController {
    @IBOutlet weak var wordsLabel: UILabel!
    @IBOutlet weak var themeLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        refresh()
    }
    
    private func refresh() {
        wordsLabel.text = HMContentController.sharedInstance.currentWords?.name
        themeLabel.text = HMContentController.sharedInstance.currentTheme?.name
    }
}
