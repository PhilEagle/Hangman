//
//  HMMusicCell.swift
//  Swift Hangman
//
//  Created by philippe eggel on 01/12/2015.
//  Copyright © 2015 PhilEagleDev. All rights reserved.
//

import UIKit

class HMMusicCell: UITableViewCell {

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
