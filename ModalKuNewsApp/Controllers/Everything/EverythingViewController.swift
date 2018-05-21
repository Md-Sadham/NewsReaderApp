//
//  EverythingViewController.swift
//  ModalKuNewsApp
//
//  Created by Naveen kumar R on 17/05/18.
//  Copyright © 2018 HMD. All rights reserved.
//

import UIKit

class EverythingViewController: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    // MARK: Variables
    @IBOutlet weak var vwSearchbar: UIView!
    @IBOutlet weak var lblNoNewsFound: UILabel!
    
    @IBOutlet weak var tblvwEverythingNews: UITableView!
    @IBOutlet weak var btnSources: UIButton!
    @IBOutlet weak var btnLanguages: UIButton!
    @IBOutlet weak var btnSortBy: UIButton!
    @IBOutlet weak var txtfldSearchKeyword: UITextField!
    
    @IBOutlet weak var scrollvwFlashNews: UIScrollView!
    @IBOutlet weak var pagerFlashNews: UIPageControl!
    
    var progressVwObj : ProgressVc!
    
    //Custom Picker Instance variable
    var customPickerObj : CustomPicker!
    var selectedPicker      = ""
    
    enum PresentPickerType : String
    {
        case Language = "language"
        case SortBy = "sortBy"
        case Sources = "sources"
    }
    
    // News.org provided many languages. I listed few only.
    var dictLanguages : Dictionary<String,String> = ["-All Languages-":"","English":"en", "French":"fr", "Chinese":"zh", "Arabic":"ar", "Spanish":"es"] //
    var dictSortby : Dictionary<String,String> = ["Relevancy":"relevancy", "Popularity":"popularity", "Published At (Default)":"publishedAt"]
    var arrSourcesNames : [String] = ["All Sources"]

    var arrNewsList : Array<NewsModal> = []
    
    var arrFlashNewsImages : [String] = ["ImageComingSoon","ImageComingSoon","ImageComingSoon"] // TEMP Images
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupInitialUI()
        
        createCustomPickerInstance()
        
        prepareCallApiRequestUrl()
    }
    
    // MARK: - Local Methods
    func setupInitialUI() {
        lblNoNewsFound .isHidden = true
        vwSearchbar .addBorders(edges: .bottom, color: .lightGray, inset: 0.0, thickness: 1.0)
        
        loadScrollView(pgCount: 3.0)
        
        // Hide table initally
        tblvwEverythingNews .isHidden = true
        tblvwEverythingNews.tableFooterView = UIView(frame: .zero)
        
        UserDefaults.standard.removeObject(forKey: "UserLastLanguage")
        UserDefaults.standard.removeObject(forKey: "UserLastSortBy")
        UserDefaults.standard.removeObject(forKey: "UserLastSources")
    }
    
    func updateLanguageInUserDefaults(language: String) {
        let defaults = UserDefaults.standard
        defaults .set(language, forKey: "UserLastLanguage")
        defaults .synchronize()
        
        btnLanguages .setTitle(language, for: .normal)
    }
    
    func updateSortByInUserDefaults(sortBy: String) {
        let defaults = UserDefaults.standard
        defaults .set(sortBy, forKey: "UserLastSortBy")
        defaults .synchronize()
        
        btnSortBy .setTitle(sortBy, for: .normal)
    }
    
    func updateSourcesInUserDefaults(source: String) {
        let defaults = UserDefaults.standard
        defaults .set(source, forKey: "UserLastSources")
        defaults .synchronize()
        
        btnSources .setTitle(source, for: .normal)
    }
    
    // MARK: - Flash News Pager-1
    func loadScrollView(pgCount : CGFloat) {
        // Pager
        let pageCount : CGFloat = pgCount
        
        scrollvwFlashNews.delegate = self
        scrollvwFlashNews.backgroundColor = UIColor .clear
        scrollvwFlashNews .isPagingEnabled = true
        scrollvwFlashNews .showsHorizontalScrollIndicator = false
        scrollvwFlashNews.contentSize = CGSize(width: GlobalConstants.ScreenSize.SCREEN_WIDTH * pageCount, height: scrollvwFlashNews.frame.size.height)
        
        pagerFlashNews.numberOfPages = Int(pageCount)
        pagerFlashNews.addTarget(self, action: #selector(self.pageChanged), for: .valueChanged)
        
        // Hide below items initally
        scrollvwFlashNews .isHidden = true
        pagerFlashNews .isHidden = true
    }
    
    @objc func pageChanged() {
        let pageNumber = pagerFlashNews.currentPage
        var frame = pagerFlashNews.frame
        frame.origin.x = frame.size.width * CGFloat(pageNumber)
        frame.origin.y = 0
        scrollvwFlashNews.scrollRectToVisible(frame, animated: true)
    }
    
    //MARK: ~ UIScrollView Delegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let viewWidth: CGFloat = GlobalConstants.ScreenSize.SCREEN_WIDTH
        // content offset - tells by how much the scroll view has scrolled.
        let pageNumber = floor((scrollView.contentOffset.x - viewWidth / 50) / viewWidth) + 1
        pagerFlashNews.currentPage = Int(pageNumber)
    }
    
    // MARK: - API Methods
    func prepareCallApiRequestUrl() {
        
        // Search keyword
        var requestParameters = "&q=" // default
        if (txtfldSearchKeyword.text != "") {
            let searchKeywordWithEncoded = GlobalConstants.urlRequestParamEncoding(reqParam: txtfldSearchKeyword.text!)
            requestParameters = requestParameters + searchKeywordWithEncoded
        }
        
        // Source
        if UserDefaults.standard.object(forKey: "UserLastSources") != nil {
            let userSource : String = UserDefaults.standard.value(forKey: "UserLastSources") as? String ?? ""
            if(userSource != "All Sources" && arrSourcesNames.contains(userSource)){
                requestParameters = requestParameters + "&sources=" + (userSource.lowercased())
            }
        }
        
        // Check request parameter
        // for handle following condt which followed by news-org: "Required parameters are missing, the scope of your search is too broad.
        // Please set any of the following required parameters and try again: q, sources, domains."
        // So, check whether user choosed source or search keyword. If both are missing, then put domains as temp.
        if (requestParameters == "&q="){
            // put domains as temp values
            requestParameters = "&domains=bbc.co.uk"
        }
        
        // Sort by
        if UserDefaults.standard.object(forKey: "UserLastSortBy") != nil {
            let userSortby : String = UserDefaults.standard.value(forKey: "UserLastSortBy") as? String ?? ""
            requestParameters = requestParameters + "&sortBy=" + dictSortby[userSortby]!
        }
        
        // Language
        if UserDefaults.standard.object(forKey: "UserLastLanguage") != nil {
            let arrLangKeys : [String] = Array(dictLanguages.keys)
            let userLanguage : String = UserDefaults.standard.value(forKey: "UserLastLanguage") as? String ?? ""
            if userLanguage != "-All Languages-" && arrLangKeys.contains(userLanguage) {
                requestParameters = requestParameters + "&language=" + dictLanguages[userLanguage]!
            }
        }
        
        print("REQ PARAM: ", requestParameters)
        
        // Remove all subviews of pager scroll view
        for view in scrollvwFlashNews.subviews{
            view.removeFromSuperview()
        }
        
        callEverythingApi(requestParameters: requestParameters)
    }
    
    func callEverythingApi(requestParameters: String) {
        
        lblNoNewsFound .isHidden = true
        createAndStartCustomProgressVw(progressText: "Collecting News")
        
        let newsModal = NewsModal()
        
        let webServiceObj = WebServiceManager.webServiceManagerSharedInstance
        webServiceObj.getRequestedArticles(newsModalObj: newsModal, endpoint: "everything", userInput: requestParameters, Success: { (newsModalSuccessObj : Array<NewsModal>) in
            
            // api response
            self.arrNewsList = newsModalSuccessObj
            
            DispatchQueue.main.async {
                
                if(self.arrNewsList.count == 0){
                    self.lblNoNewsFound .isHidden = false
                    
                    self.pagerFlashNews .isHidden = true
                    self.scrollvwFlashNews .isHidden = true
                    self.tblvwEverythingNews .isHidden = true
                }
                else {
                    self.refreshPager(arrModalObj: self.arrNewsList)
                    
                    self.tblvwEverythingNews .isHidden = false
                    self.tblvwEverythingNews .reloadData()
                }
                
                self.removeProgressVw()
            }
            
        }, Failure: { (error) in
            print("VC - Error : \(error)")
            
            DispatchQueue.main.async {
                self.removeProgressVw()
            }
            
            GlobalConstants.showSuccessFailureAlertWithDismissHandler(title: GlobalConstants.readProductNameFromPlist(), message: error, okTitle: "Ok", controller: self, alertDismissed: { (dismissed) in
            })
        })
    }
    
    // MARK: - Flash News Pager-2
    func refreshPager(arrModalObj : Array<NewsModal>) {
        
        if(arrModalObj.count <= 3){
            self.loadScrollView(pgCount: CGFloat(arrModalObj.count))
        }
        
        // give visibility now
        self.scrollvwFlashNews .isHidden = false
        self.pagerFlashNews .isHidden = false
        
        for i in 0..<Int(pagerFlashNews.numberOfPages) {
            
            let modalObj : NewsModal = arrModalObj[i]
            
            // 1a
            let imgView = UIImageView(frame: CGRect(x:GlobalConstants.ScreenSize.SCREEN_WIDTH * CGFloat(i), y:0, width:GlobalConstants.ScreenSize.SCREEN_WIDTH, height:self.scrollvwFlashNews.frame.size.height))
            imgView.image = UIImage(named: arrFlashNewsImages[i])!
            imgView.contentMode = .scaleAspectFit
            self.scrollvwFlashNews.addSubview(imgView)
            
            // 1b
            print("X POS: ", (GlobalConstants.ScreenSize.SCREEN_WIDTH * CGFloat(i)) + 8)
            let lblFlashNewsTitle = UILabel(frame: CGRect(x:(GlobalConstants.ScreenSize.SCREEN_WIDTH * CGFloat(i)) + 8, y:60, width:GlobalConstants.ScreenSize.SCREEN_WIDTH-16, height:30))
            lblFlashNewsTitle.backgroundColor = UIColor.black.withAlphaComponent(0.5) //UIColor(red: 201, green: 219, blue: 220, alpha: 1.0)
            lblFlashNewsTitle.textColor = UIColor.white
            lblFlashNewsTitle.font = UIFont(name: "GillSans-Bold", size: 12)
            lblFlashNewsTitle.text = modalObj.title
            self.scrollvwFlashNews.addSubview(lblFlashNewsTitle)
            self.scrollvwFlashNews.bringSubview(toFront: lblFlashNewsTitle)
            
            // 2
            let imageUrlString = modalObj.urlToImage
            if !GlobalConstants.verifyUrl(urlString: imageUrlString) {
                imgView.image = #imageLiteral(resourceName: "NoImage") // No image
                continue
            }
            else {
                imgView.image = #imageLiteral(resourceName: "ImageComingSoon") // image coming soon
            }
            
            // 3
            let imageUrl = URL(string: imageUrlString!)
            DispatchQueue.global().async {
                
                let data = try? Data(contentsOf: imageUrl!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                DispatchQueue.main.async {
                    
                    guard let imageData = data else {
                        print("image data is nil. set default thumb image")
                        imgView.image = #imageLiteral(resourceName: "NoImage") // No image
                        return
                    }
                    
                    imgView.contentMode = .scaleToFill
                    imgView.image = UIImage(data: imageData)
                }
            }
        }
        
    }
    
    // MARK: - Button Action
    @IBAction func actionSearch(_ sender: Any) {
        
        if(txtfldSearchKeyword.text != ""){
            prepareCallApiRequestUrl()
        }
    }
    
    @IBAction func chooseLanguage(_ sender: Any) {
        let languagesInSet = Set(Array(self.dictLanguages.keys))
        let arrLanguagesNames = languagesInSet.sorted()
        loadPickerWithData(listData: arrLanguagesNames, type: PresentPickerType.Language.rawValue)
    }
    
    @IBAction func chooseSortby(_ sender: Any) {
        let arrSortby = Array(dictSortby.keys)
        loadPickerWithData(listData: arrSortby, type: PresentPickerType.SortBy.rawValue)
    }
    
    @IBAction func chooseSource(_ sender: Any) {
        
        if(arrSourcesNames.count > 1){
            self.loadPickerWithData(listData: self.arrSourcesNames, type: PresentPickerType.Sources.rawValue)
            return
        }
        
        // Call API
        createAndStartCustomProgressVw(progressText: "Retrieving Sources List")
        
        let sourceModal = SourcesModal()
        let webServiceObj = WebServiceManager.webServiceManagerSharedInstance
        webServiceObj.getRequestSourcesList(sourceModalObj: sourceModal, userInput: "", Success: { (sourceModalSuccessObj : Array<SourcesModal>) in
            
            let sourceModalObj : Array<SourcesModal> = sourceModalSuccessObj
            
            for source in sourceModalObj {
                self.arrSourcesNames.append(source.articleSourceId!)
            }
            
            DispatchQueue.main.async {
                self.removeProgressVw()
                
                self.loadPickerWithData(listData: self.arrSourcesNames, type: PresentPickerType.Sources.rawValue)
            }
            
        }, Failure: { (error) in
            self.removeProgressVw()
            
            GlobalConstants.showSuccessFailureAlertWithDismissHandler(title: GlobalConstants.readProductNameFromPlist(), message: error, okTitle: "Ok", controller: self, alertDismissed: { (dismissed) in
            })
        })
    }
    
    
    // MARK: - Progress Indicator
    func createAndStartCustomProgressVw(progressText: String)
    {
        // check if its already exist
        removeProgressVw()
        
        //Initialize customPicker
        progressVwObj = (self.storyboard?.instantiateViewController(withIdentifier: "ProgressVc")) as! ProgressVc
        self.view.addSubview(progressVwObj.view)
        progressVwObj.startProgressLoader(progressText: progressText)
    }
    
    func removeProgressVw()
    {
        if progressVwObj != nil
        {
            progressVwObj.stopProgressLoader()
            progressVwObj.view.removeFromSuperview()
        }
    }
    
    // MARK: - Textfield Delegates
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        txtfldSearchKeyword .resignFirstResponder()
        prepareCallApiRequestUrl()
        
        return true
    }
    
    // MARK: - Extra
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("home touches")
        
        txtfldSearchKeyword .resignFirstResponder()
    }
}

// MARK: - Extension

// MARK: ~ Picker
extension EverythingViewController : CustomPickerDelegate {
    // MARK: - Picker
    func createCustomPickerInstance()
    {
        customPickerObj = GlobalConstants.getCustomPickerInstance()
        customPickerObj.delegate = self
    }
    
    func loadPickerWithData(listData: [String], type: String)
    {
        selectedPicker = type
        customPickerObj.totalComponents = 1
        customPickerObj.arrayComponent = listData
        addCustomPicker()
        customPickerObj.loadCustomPicker(pickerType: CustomPickerType.e_PickerType_String)
        customPickerObj.customPicker.reloadAllComponents()
    }
    
    func addCustomPicker() {
        self.view.addSubview(customPickerObj.view)
    }
    
    func removeCustomPicker()
    {
        if customPickerObj != nil
        {
            customPickerObj.view.removeFromSuperview()
        }
    }
    
    func itemPicked(item: AnyObject) {
        
        let pickerValue = item as! String
        print("Item Selected : \(pickerValue)")
        
        removeCustomPicker()
        
        if (selectedPicker == PresentPickerType.Sources.rawValue) {
            btnSources .setTitle(pickerValue, for: .normal)
            
            self.updateSourcesInUserDefaults(source: pickerValue)
        }
        else if (selectedPicker == PresentPickerType.Language.rawValue) {
            btnLanguages .setTitle(pickerValue, for: .normal)
            
            self.updateLanguageInUserDefaults(language: pickerValue)
        }
        else if (selectedPicker == PresentPickerType.SortBy.rawValue) {
            btnSortBy .setTitle(pickerValue, for: .normal)
            
            self.updateSortByInUserDefaults(sortBy: pickerValue)
        }
        
        prepareCallApiRequestUrl()
        selectedPicker = ""
    }
    
    func pickerCancelled()
    {
        removeCustomPicker()
        selectedPicker = ""
    }
}

extension EverythingViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.arrNewsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let strIdentifier = "EverythingCellId"
        let cell : EverythingTableViewCell = tableView.dequeueReusableCell(withIdentifier: strIdentifier, for: indexPath) as! EverythingTableViewCell
        
        cell.addBorders(edges: [.bottom], color: .lightGray, inset: 0.0, thickness: 1.0)
        
        let article : NewsModal = arrNewsList[indexPath.row]
        cell.lblNewsTitle.text = article.title
        cell.lblNewsSource.text = article.articleSourceName
        
        // Download image
        let imageUrlString = article.urlToImage
        cell.imgvwEverythingNews.contentMode = .scaleAspectFit
        
        if !GlobalConstants.verifyUrl(urlString: imageUrlString) {
            cell.imgvwEverythingNews.image = #imageLiteral(resourceName: "NoImage")
            return cell
        }
        
        if let imageUrl = URL(string: imageUrlString!) {
            URLSession.shared.dataTask(with: URLRequest(url: imageUrl)) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imgvwEverythingNews.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.imgvwEverythingNews.image = #imageLiteral(resourceName: "ImageComingSoon")
                    }
                }
                }.resume()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = GlobalConstants.getMainStoryboardInstance()
        let controller = storyboard.instantiateViewController(withIdentifier: "DetailVcId") as! DetailViewController
        controller.newsModalObj = arrNewsList[indexPath.row]
        
        self.navigationController?.pushViewController(controller, animated: true)
        
        tableView .deselectRow(at: indexPath, animated: true)
    }
}
