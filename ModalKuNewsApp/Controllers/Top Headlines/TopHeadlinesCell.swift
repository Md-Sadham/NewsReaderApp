//
//  TopHeadlinesCell.swift
//  ModalKuNewsApp
//
//  Created by Naveen kumar R on 18/05/18.
//  Copyright © 2018 HMD. All rights reserved.
//

import UIKit

class TopHeadlinesCell: UICollectionViewCell {
    
    @IBOutlet weak var imgHeadlines: UIImageView!
    
    @IBOutlet weak var lblHeadlinesTitle: UILabel!
    
    @IBOutlet weak var lblHeadlinesAuthor: UILabel!
    
    func displayContent(headlinesModal : NewsModal) {
        lblHeadlinesTitle.text = headlinesModal.title
        lblHeadlinesAuthor.text = headlinesModal.authorName
    }
}
