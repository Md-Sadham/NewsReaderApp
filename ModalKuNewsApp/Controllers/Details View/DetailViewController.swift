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
    
    @IBOutlet weak var btnBookmark: UIButton!
    
    @IBOutlet weak var layoutDescTxtvwBottom: NSLayoutConstraint!

    var redirectFromWhichPage = ""
    
    var newsModalObj : NewsModal?
    
    var bookmarkModalObj : BookmarkModal?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupInitialUi()
        
        setupNewsDescription()
    }
    
    // MARK: - Local Methods
    private func setupInitialUi() {
        
        lblNewsTitle.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        lblNewsAuthor.verticalAlignment = .top
        imgVwNews.addBorders(edges: .bottom, color: .lightGray, inset: 0.0, thickness: 1.0)
        
        btnBookmark .isHidden = false
        layoutDescTxtvwBottom.constant = 50
        
        switch redirectFromWhichPage {
        case "Headlines", "Everything":
            checkWhetherThisNewsIsListedInBookmark()
        case "Bookmark":
            self.btnBookmark .tag = 2
            self.btnBookmark .setTitle("Remove from Bookmarks", for: .normal)
        default:
            break
        }
    }
    
    func checkWhetherThisNewsIsListedInBookmark() {
        let bookmodalObj = BookmarkModal()
        let bIsPresent = bookmodalObj.checkWhetherThisNewsIsListedInBookmark(modalObj: newsModalObj!)
        
        self.btnBookmark .tag = 1
        self.btnBookmark .setTitle("Bookmark This News", for: .normal)
        if bIsPresent {
            self.btnBookmark .tag = 2
            self.btnBookmark .setTitle("Remove from Bookmarks", for: .normal)
        }
    }
    
    // MARK: - Unwrap Modal
    func setupNewsDescription() {
        
        var imgUrlString = ""
        
        switch redirectFromWhichPage {
        case "Headlines", "Everything":
            txtVwNewsDescription.text = newsModalObj?.articleDescription ?? "-- Description is not provided by source or by server --"
            lblNewsTitle.text = newsModalObj?.title
            lblNewsAuthor.text = newsModalObj?.authorName
            lblNewsSource.text = newsModalObj?.articleSourceName
            lblNewsPublishedAt.text = newsModalObj?.publishedAt
            imgUrlString = (newsModalObj?.urlToImage)!
        case "Bookmark":
            txtVwNewsDescription.text = bookmarkModalObj?.articleDescription ?? "-- Description is not provided by source or by server --"
            lblNewsTitle.text = bookmarkModalObj?.title
            lblNewsAuthor.text = bookmarkModalObj?.authorName
            lblNewsSource.text = bookmarkModalObj?.articleSourceName
            lblNewsPublishedAt.text = bookmarkModalObj?.publishedAt
            imgUrlString = (bookmarkModalObj?.urlToImage)!
        default:
            break
        }
        
        // Check whether image url is valid or not. If not, set thumb and return it.
        imgVwNews.contentMode = .scaleAspectFit
        if !GlobalConstants.verifyUrl(urlString: imgUrlString) {
            imgVwNews.image = #imageLiteral(resourceName: "NoImage") // No Image
            return
        }
        else {
            imgVwNews.image = #imageLiteral(resourceName: "ImageComingSoon") // Image coming soon
        }
        
        // Download images in background thread asynchronously
        if let imageUrl = URL(string: imgUrlString) {
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
    
    // MARK: - Button Action

    @IBAction func bookmarkThisPage(_ sender: UIButton) {
        
        // Tag : 1 - title : "Bookmark this news"
        // Tag : 2 - title : "Remove fom bookmark"
        
        switch sender.tag {
        case 1:
            let bookmodalObj = BookmarkModal()
            let bIsSuccess = bookmodalObj.saveNewsInBookmarkTable(modalObj: newsModalObj!)
            
            if bIsSuccess {
                GlobalConstants.showSuccessFailureAlertWithDismissHandler(title: GlobalConstants.readProductNameFromPlist(), message: "Saved to Bookmarks Successfully", okTitle: "Ok", controller: self) { (dismissed) in
                    self.btnBookmark .tag = 2
                    self.btnBookmark .setTitle("Remove from Bookmarks", for: .normal)
                }
            }
        case 2:
            let bookmodalObj = BookmarkModal()
            
            var bIsSuccess = false
            if(newsModalObj != nil){
                bIsSuccess = bookmodalObj.removeNewsFromBookmarkTable(modalObj: newsModalObj!)
            }
            else{
                bIsSuccess = bookmodalObj.removeBookmarkThroughBookmarkList(modalObj: bookmarkModalObj!)
            }
            
            //
            if bIsSuccess {
                GlobalConstants.showSuccessFailureAlertWithDismissHandler(title: GlobalConstants.readProductNameFromPlist(), message: "Removed from Bookmarks Successfully", okTitle: "Ok", controller: self) { (dismissed) in
                    self.btnBookmark .tag = 1
                    self.btnBookmark .setTitle("Bookmark This News", for: .normal)
                    
                    if(self.bookmarkModalObj != nil){
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            
        default:
            break
        }
        
        
    }
}
