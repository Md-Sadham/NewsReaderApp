//
//  BookMarkViewController.swift
//  ModalKuNewsApp
//
//  Created by Naveen kumar R on 21/05/18.
//  Copyright © 2018 HMD. All rights reserved.
//

import UIKit

class BookMarkViewController: UIViewController {
    
    @IBOutlet weak var tblvwBookmarkList: UITableView!
    
    var arrBookmarkModalObj : Array<BookmarkModal> = []

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tblvwBookmarkList.tableFooterView = UIView(frame: .zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        readListDataFromDb()
    }
    
    func readListDataFromDb() {
        let bookmodalObj = BookmarkModal()
        arrBookmarkModalObj = bookmodalObj.retriveAllListOfBookmarks()
        
        if(arrBookmarkModalObj.count == 0){
            tblvwBookmarkList .isHidden = true
            return
        }
        tblvwBookmarkList .isHidden = false
        tblvwBookmarkList .reloadData()
    }
    
}

// Extension
extension BookMarkViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrBookmarkModalObj.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let strIdentifier = "BookmarkCellId"
        let cell : BookmarkCell = tableView.dequeueReusableCell(withIdentifier: strIdentifier, for: indexPath) as! BookmarkCell
        
        let bookmarkModalObj : BookmarkModal = arrBookmarkModalObj[indexPath.row]
        
        cell.lblNewsTitle.text = bookmarkModalObj.title ?? ""
        cell.lblNewsSource.text = bookmarkModalObj.articleSourceName ?? ""
        
        // Download image
        let imageUrlString = bookmarkModalObj.urlToImage
        cell.imgvwNews.contentMode = .scaleAspectFit
        
        if Reachability.isConnectedToNetwork() == false {
            cell.imgvwNews.image = #imageLiteral(resourceName: "NoImage")
            return cell
        }
        else if !GlobalConstants.verifyUrl(urlString: imageUrlString) {
            cell.imgvwNews.image = #imageLiteral(resourceName: "NoImage")
            return cell
        }
        
        if let imageUrl = URL(string: imageUrlString!) {
            URLSession.shared.dataTask(with: URLRequest(url: imageUrl)) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imgvwNews.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.imgvwNews.image = #imageLiteral(resourceName: "ImageComingSoon")
                    }
                }
                }.resume()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = GlobalConstants.getMainStoryboardInstance()
        let controller = storyboard.instantiateViewController(withIdentifier: "DetailVcId") as! DetailViewController
        controller.redirectFromWhichPage = "Bookmark"
        controller.bookmarkModalObj = arrBookmarkModalObj[indexPath.row]
        
        self.navigationController?.pushViewController(controller, animated: true)
        
        tableView .deselectRow(at: indexPath, animated: true)
    }
}
