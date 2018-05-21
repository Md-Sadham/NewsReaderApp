//
//  EverythingTableViewCell.swift
//  ModalKuNewsApp
//
//  Created by Naveen kumar R on 20/05/18.
//  Copyright © 2018 HMD. All rights reserved.
//

import UIKit

class EverythingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgvwEverythingNews: UIImageView!
    
    @IBOutlet weak var lblNewsTitle: TopAlignForMultilineLabel!
    
    @IBOutlet weak var lblNewsSource: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
