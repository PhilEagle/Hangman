//
//  HMStoreListViewCell.swift
//  Hangman
//
//  Created by phil on 02/11/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import UIKit

class HMStoreListViewCell: UITableViewCell {

    @IBOutlet weak var outerImageView: UIView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let radius = CGFloat(12.0)
        
        self.iconImageView.hidden = false
        
        self.iconImageView.layer.masksToBounds = true
        self.iconImageView.layer.borderColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.8).CGColor
        self.iconImageView.layer.borderWidth = 1.0
        self.iconImageView.layer.cornerRadius = radius
        
        self.outerImageView.layer.shadowColor = UIColor.blackColor().CGColor
        self.outerImageView.layer.shadowOffset = CGSize(width: 0, height: 3)
        self.outerImageView.layer.shadowOpacity = 0.3
        self.outerImageView.layer.shadowRadius = 3.0
        self.outerImageView.layer.cornerRadius = radius
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
