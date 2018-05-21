//
//  MenuScreenCell.swift
//  MAutoMenu
//
//  Created by Sadham Hussain on 12/22/16.
//  Copyright © 2016 CIPL-Sadham Hussain. All rights reserved.
//

import UIKit

class MenuScreenCell: UITableViewCell {

    @IBOutlet weak var lblMenuOptionText: UILabel!
    
    @IBOutlet weak var imgMenuOptionIcon: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
