//
//  HMStoreListViewControllerTableViewController.swift
//  Hangman
//
//  Created by philippe eggel on 02/11/2015.
//  Copyright © 2015 Ray Wenderlich. All rights reserved.
//

import UIKit

class HMStoreDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(patternImage:UIImage(named: "bg.png")!)
    }

    // MARK: - CallBacks
    func buyTapped(sender: UIButton) {
    }
    
    @IBAction func pauseTapped(sender: UIButton) {
    }
    
    @IBAction func resumeTapped(sender: UIButton) {
    }
    
    @IBAction func cancelTapped(sender: UIButton) {
    }

}
