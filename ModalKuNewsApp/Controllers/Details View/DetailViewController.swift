//
//  DetailViewController.swift
//  ModalKuNewsApp
//
//  Created by Naveen kumar R on 19/05/18.
//  Copyright © 2018 HMD. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var imgVwNews: UIImageView!
    @IBOutlet weak var lblNewsTitle: UILabel!
    @IBOutlet weak var lblNewsPublishedAt: UILabel!
    @IBOutlet weak var lblNewsSource: UILabel!
    @IBOutlet weak var lblNewsAuthor: TopAlignForMultilineLabel!
    
    @IBOutlet weak var txtVwNewsDescription: UITextView!
    
    var newsModalObj : NewsModal?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        lblNewsAuthor.verticalAlignment = .top
        imgVwNews.addBorders(edges: .bottom, color: .lightGray, inset: 0.0, thickness: 1.0)
        
        setupNewsDescription()
    }
    
    func setupNewsDescription() {
        
        txtVwNewsDescription.text = newsModalObj?.articleDescription ?? "-- Description is not provided by source or by server --"
        
        lblNewsTitle.text = newsModalObj?.title
        lblNewsAuthor.text = newsModalObj?.authorName
        lblNewsSource.text = newsModalObj?.articleSourceName
        lblNewsPublishedAt.text = newsModalObj?.publishedAt
        
        // Check whether image url is valid or not. If not, set thumb and return it.
        let imgUrlString = newsModalObj?.urlToImage
        imgVwNews.contentMode = .scaleAspectFit
        if !GlobalConstants.verifyUrl(urlString: imgUrlString) {
            imgVwNews.image = #imageLiteral(resourceName: "NoImage") // No Image
            return
        }
        else {
            imgVwNews.image = #imageLiteral(resourceName: "ImageComingSoon") // Image coming soon
        }
        
        // Download images in background thread asynchronously
        if let imageUrl = URL(string: imgUrlString!) {
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageUrl) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    self.imgVwNews.contentMode = .scaleToFill
                    
                    guard let imageData = data else {
                        print("image data is nil. set default thumb image")
                        self.imgVwNews.image = #imageLiteral(resourceName: "NoImage")
                        return
                    }
                    
                    self.imgVwNews.image = UIImage(data: imageData)
                }
            }
        }
        
    }
}
