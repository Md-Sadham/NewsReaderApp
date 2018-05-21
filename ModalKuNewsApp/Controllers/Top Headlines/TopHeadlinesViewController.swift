//
//  TopHeadlinesViewController.swift
//  ModalKuNewsApp
//
//  Created by Naveen kumar R on 16/05/18.
//  Copyright © 2018 HMD. All rights reserved.
//

import UIKit
import CoreLocation

class TopHeadlinesViewController: UIViewController {
    
    // MARK: - Variables
    // Outlets
    @IBOutlet weak var vwUserInputs: UIView!
    @IBOutlet weak var collvwTopHeadlines: UICollectionView!
    
    @IBOutlet weak var btnCountry: UIButton! // Default title: "Choose Country"
    @IBOutlet weak var btnCategory: UIButton! // Default title: "Choose Category"
    
    var progressVwObj : ProgressVc!
    
    // Custom Picker Instance variable
    var customPickerObj : CustomPicker!
    var selectedPicker      = ""
    
    let locationManager = CLLocationManager()
    
    // Api input Variables
    var arrCategoryName : [String] = ["All Categories","Business","Entertainment","General","Health","Science","Sports","Technology"]
    var dictCountriesWithCode : Dictionary<String,String> = ["-Detect My Location-": "", "Malaysia":"my", "Singapore":"sg", "India":"in", "China":"cn", "United Arab Emirates":"ae","United States":"us"] // News.org provided many countries. I listed few only.
    
    var arrArticlesList : Array<NewsModal> = []
    
    // For Menu
    private lazy var menuViewController : MenuViewController = {
        // Load Storyboard
        let storyboard = GlobalConstants.getMainStoryboardInstance()
        
        // Instantiate View Controller
        let menuVc = storyboard.instantiateViewController(withIdentifier: "MenuVcId") as! MenuViewController
        
        // Add View Controller as Child View Controller
        self.add(asChildViewController: menuVc)
        
        return menuVc
    }()
    
    enum PresentPickerType : String
    {
        case Country = "country"
        case Category = "category"
    }
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupNavBar()
        
        createCustomPickerInstance()
        
        setupInitialUi()
        
        // Notification
        addNotificationObserverForMenuSelection()
        
        // Initial call api after detect location result
        detectLocation()
    }
    
    // MARK: - Local Methods
    private func setupNavBar(){        
        let menuBtn = UIButton.init(type: .custom)
        menuBtn .setBackgroundImage(#imageLiteral(resourceName: "Menu"), for: .normal)
        menuBtn.frame = CGRect.init(x: 0, y: 0, width: 0, height: 0)
        menuBtn.widthAnchor.constraint(equalToConstant: 32.0).isActive = true
        menuBtn.heightAnchor.constraint(equalToConstant: 32.0).isActive = true
        menuBtn.addTarget(self, action:#selector(TopHeadlinesViewController.openMenu), for:.touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: menuBtn)
    }
    
    private func setupInitialUi() {
        
        vwUserInputs.addBorders(edges: .bottom, color: .lightGray, inset: 0.0, thickness: 1.0)
        
        if(UserDefaults.standard.object(forKey: "UserLastCountry") != nil){
            btnCountry .setTitle(UserDefaults.standard.value(forKey: "UserLastCountry") as? String, for: .normal)
        }
        
        if(UserDefaults.standard.object(forKey: "UserLastCategory") != nil){
            btnCategory .setTitle(UserDefaults.standard.value(forKey: "UserLastCategory") as? String, for: .normal)
        }
    }
    
    func updateCountryInUserDefaults(country: String) {
        let defaults = UserDefaults.standard
        defaults .set(country, forKey: "UserLastCountry")
        defaults .synchronize()
        
        btnCountry .setTitle(country, for: .normal)
    }
    
    func updateCategoryInUserDefaults(category: String) {
        let defaults = UserDefaults.standard
        defaults .set(category, forKey: "UserLastCategory")
        defaults .synchronize()
        
        btnCategory .setTitle(category, for: .normal)
    }
    
    // MARK: - Detect Location
    func detectLocation() {
        createAndStartCustomProgressVw(progressText: "Detecting Location")
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("notDetermined")
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
            break
            
        case .restricted, .denied:
            // Disable location features
            print("restricted")
            removeProgressVw()
            
            GlobalConstants.showSuccessFailureAlertWithDismissHandler(title: GlobalConstants.readProductNameFromPlist(), message: "Location Access has been denied for Modalku News!. Please allow it through your iPhone Settings.", okTitle: "Ok", controller: self) { (dismissed) in
                self.btnCountry .setTitle("Choose Country", for: .normal)
                UserDefaults.standard.removeObject(forKey: "UserLastCountry")
            }
            
            //"Location Access has been denied for Modalku News!. Please allow it through your iPhone Settings."
            
            prepareCallApiRequestUrl()
            break
            
        case .authorizedWhenInUse:
            // Enable basic location features
            print("authorizedWhenInUse")
            locationManager.startUpdatingLocation()
            break
            
        case .authorizedAlways:
            // Enable any of your app's location features
            print("authorizedAlways")
            locationManager.startUpdatingLocation()
            break
        }
    }
    
    // MARK: - Menu Function
    @objc func openMenu(){
        print("Open menu")
        
        if self.childViewControllers.count > 0 {
            remove(asChildViewController: menuViewController)
        }
        else {
            add(asChildViewController: menuViewController)
        }
    }
    
    func checkBeforeRemoveChildView(){
        // remove menu
        if self.childViewControllers.count > 0 {
            remove(asChildViewController: menuViewController)
        }
    }
    
    private func add(asChildViewController childViewController: UIViewController) {
        // Add Child View Controller
        addChildViewController(childViewController)
        
        // Add Child View as Subview
        view.addSubview(childViewController.view)
        
        // Configure Child View
        childViewController.view.frame = CGRect(x: 0, y: 0, width: GlobalConstants.ScreenSize.SCREEN_WIDTH, height: GlobalConstants.ScreenSize.SCREEN_HEIGHT)
        childViewController.view.widthAnchor.constraint(equalToConstant: GlobalConstants.ScreenSize.SCREEN_WIDTH).isActive = true
        childViewController.view.heightAnchor.constraint(equalToConstant: GlobalConstants.ScreenSize.SCREEN_HEIGHT).isActive = true
        
        childViewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController childViewController: UIViewController) {
        // Notify Child View Controller
        childViewController.willMove(toParentViewController: nil)
        
        // Remove Child View From Superview
        childViewController.view.removeFromSuperview()
        
        // Notify Child View Controller
        childViewController.removeFromParentViewController()
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
    
    // MARK: - Button Action
    @IBAction func chooseCountry(_ sender: Any) {
        let countriesInSet = Set(Array(dictCountriesWithCode.keys))
        let arrCountriesName = countriesInSet.sorted()
        loadPickerWithData(listData: arrCountriesName, type: PresentPickerType.Country.rawValue)
    }
    
    @IBAction func chooseCategory(_ sender: UIButton) {
        self.loadPickerWithData(listData: arrCategoryName, type: PresentPickerType.Category.rawValue)
    }
    
    // MARK: - API Methods
    func prepareCallApiRequestUrl() {
        
        // News.org Condition: "Required parameters are missing. Please set any of the following parameters
        // and try again: sources, q, language, country, category"
        // Handle:
        // so set default language as English (en)
        
        
        // 1 Default
        var requestParameters = ""
        
        // 2 If country is exist, remove above default value
        if UserDefaults.standard.object(forKey: "UserLastCountry") != nil {
            
            var strCountryCode = ""
            let userCountry : String = UserDefaults.standard.value(forKey: "UserLastCountry") as? String ?? ""
            if(dictCountriesWithCode.index(forKey: userCountry) != nil){
                strCountryCode = dictCountriesWithCode[userCountry]!
            }
            
            requestParameters = "&country=" + strCountryCode
        }
        
        // 3
        if UserDefaults.standard.object(forKey: "UserLastCategory") != nil {
            let userCategory : String = UserDefaults.standard.value(forKey: "UserLastCategory") as? String ?? ""
            if(userCategory != "All Categories" && arrCategoryName.contains(userCategory)){
                if(requestParameters == ""){
                    requestParameters = "&category=" + (userCategory.lowercased())
                }
                else{
                    requestParameters = requestParameters + "&category=" + (userCategory.lowercased())
                }
            }
        }
        
        // 4 If request Param is empty, then set language as english as default
        if(requestParameters == "" || requestParameters == "&country="){
            requestParameters = "&language=en"
        }
        
        print("Print request: \(requestParameters)")
        
        callTopHeadlinesApi(requestParameters: requestParameters)
    }
    
    func callTopHeadlinesApi(requestParameters: String) {
        createAndStartCustomProgressVw(progressText: "Collecting News")
        
        let newsModal = NewsModal()
        
        let webServiceObj = WebServiceManager.webServiceManagerSharedInstance
        webServiceObj.getRequestedArticles(newsModalObj: newsModal, endpoint: "top-headlines", userInput: requestParameters, Success: { (newsModalSuccessObj : Array<NewsModal>) in
            
            self.arrArticlesList = newsModalSuccessObj
            
            DispatchQueue.main.async {
                self.collvwTopHeadlines .reloadData()

                self.removeProgressVw()
            }
            
        }, Failure: { (error) in
            print("VC - Error : \(error)")
            
            GlobalConstants.showSuccessFailureAlertWithDismissHandler(title: GlobalConstants.readProductNameFromPlist(), message: error, okTitle: "Ok", controller: self, alertDismissed: { (dismissed) in
            })
            
            DispatchQueue.main.async {
                self.removeProgressVw()
            }
        })
    }
    
    // MARK: - Notification Center
    private func addNotificationObserverForMenuSelection() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(printValue(notification:)), name: Notification.Name(rawValue: "MenuSelected"), object: nil)
    }
    
    @objc func printValue(notification:NSNotification) {
        let userInfo:Dictionary<String,Any> = notification.userInfo as! Dictionary<String,Any>
        
        if userInfo.keys.contains("HideMenu") {
            checkBeforeRemoveChildView()
            return
        }
        
        let sectionIndex = userInfo["TabIndex"] as! Int
        if sectionIndex == 0 {
            // change category of news
            let selectedCategory = userInfo["SelectedCategory"] as! String
            updateCategoryInUserDefaults(category: selectedCategory)
            
            prepareCallApiRequestUrl()
        }
        else if sectionIndex == 1 {
            self.tabBarController?.selectedIndex = 1
        }
        
        checkBeforeRemoveChildView()
    }
    
    
    // MARK: - Extra
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print("home touches")
        
        if self.childViewControllers.count > 0 {
            remove(asChildViewController: menuViewController)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
}

// MARK: - Extensions

// MARK: ~ CLLocation
extension TopHeadlinesViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        locationManager.stopUpdatingLocation()
        
        var userPlacemark : CLPlacemark?
        let userLocation: CLLocation = locations[0]
        
        CLGeocoder().reverseGeocodeLocation(userLocation) { (placemarks, error) in
            
            self.removeProgressVw()
            
            if error == nil && (placemarks?.count)!>0 {
                userPlacemark = placemarks?[0]
                
                // 1 Check detected location are availablee in list
                let arrCountryCodes : [String] = Array(self.dictCountriesWithCode.values)
                if(arrCountryCodes .contains((userPlacemark?.isoCountryCode?.lowercased())!)){
                    if userPlacemark?.country != nil {
                        self.btnCountry .setTitle(userPlacemark?.country, for: .normal)
                        
                        self.updateCountryInUserDefaults(country: (userPlacemark?.country)!)
                    }
                    
                    self.prepareCallApiRequestUrl()
                }
                // Preferring Recent location
                else if UserDefaults.standard.object(forKey: "UserLastCountry") != nil {
                    GlobalConstants.showSuccessFailureAlertWithDismissHandler(title: GlobalConstants.readProductNameFromPlist(), message: "Detecting Location Failed. Preferring Recent location.", okTitle: "Ok", controller: self, alertDismissed: { (completed) in
                    })
                    
                    self.btnCountry .setTitle(UserDefaults.standard.value(forKey: "UserLastCountry") as? String ?? "Choose Country", for: .normal)
                    
                    self.prepareCallApiRequestUrl()
                }
                else {
                    GlobalConstants.showSuccessFailureAlertWithDismissHandler(title: GlobalConstants.readProductNameFromPlist(), message: "Headlines are not provided for your detected location. Please choose location from available country list", okTitle: "Choose Country", controller: self, alertDismissed: { (completed) in
                        
                        let countriesInSet = Set(Array(self.dictCountriesWithCode.keys))
                        let arrCountriesName = countriesInSet.sorted()
                        self.loadPickerWithData(listData: arrCountriesName, type: PresentPickerType.Country.rawValue)
                    })
                }
                
                print(userPlacemark?.isoCountryCode ?? "")
            }
            else {
                print("User block detect location")
                
                self.removeProgressVw()
                
                GlobalConstants.showSuccessFailureAlertWithDismissHandler(title: GlobalConstants.readProductNameFromPlist(), message: (error?.localizedDescription)!, okTitle: "Ok", controller: self, alertDismissed: { (completed) in
                })
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        
        removeProgressVw()
        
        var strMessage = ""
        
        if let clErr = error as? CLError {
            switch clErr {
            case CLError.network:
                strMessage = "Can't access your current location! Please check your network connection or that you are not in airplane mode!"
                
            case CLError.locationUnknown:
                print("location unknown")
                
                strMessage = "Your location cannot be tracking. Please choose Country / Category to get Top-Headlines"
                
            case CLError.denied:
                print("denied")
                
                strMessage = "Location Access has been denied for Modalku News!. Please allow it through your iPhone Settings."
            default:
                print("other Core Location error")
                
                strMessage = "Your location cannot be tracking. Please choose Country / Category to get Top-Headlines"
            }
        } else {
            print("other error:", error.localizedDescription)
            
            strMessage = error.localizedDescription
        }
        
        GlobalConstants.showSuccessFailureAlertWithDismissHandler(title: GlobalConstants.readProductNameFromPlist(), message: strMessage, okTitle: "Ok", controller: self) { (dismissed) in
            
        }
    }
}

// MARK: ~ Picker
extension TopHeadlinesViewController : CustomPickerDelegate {
    
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
    
    func createCustomPickerInstance()
    {
        customPickerObj = GlobalConstants.getCustomPickerInstance()
        customPickerObj.delegate = self
    }
    
    func itemPicked(item: AnyObject) {
        
        let pickerValue = item as! String
        print("Item Selected : \(pickerValue)")
        
        removeCustomPicker()
        
        if (selectedPicker == PresentPickerType.Country.rawValue) {
            
            if pickerValue.lowercased() == "-detect my location-" {
                detectLocation()
            }
            else {
                btnCountry .setTitle(pickerValue, for: .normal)
                
                self.updateCountryInUserDefaults(country: pickerValue)
                
                prepareCallApiRequestUrl()
            }
        }
        else if (selectedPicker == PresentPickerType.Category.rawValue) {
            btnCategory .setTitle(pickerValue, for: .normal)
            
            self.updateCategoryInUserDefaults(category: pickerValue)
            
            prepareCallApiRequestUrl()
        }
        
        selectedPicker = ""
        
    }
    
    func pickerCancelled()
    {
        removeCustomPicker()
        selectedPicker = ""
    }
}

// MARK: ~ Collection View
extension TopHeadlinesViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrArticlesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellId: NSString = "TopHeadlinesCellId"
        let cell : TopHeadlinesCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId as String, for: indexPath) as! TopHeadlinesCell
        
        cell.addBorders(edges: [.all], color: .lightGray, inset: 0.0, thickness: 1.0)
        
        let article : NewsModal = arrArticlesList[indexPath.row]
        cell.lblHeadlinesTitle.text = article.title
        cell.lblHeadlinesAuthor.text = article.articleSourceName
        
        // Check whether image url is valid or not. If not, set thumb and return it.
        // Download image
        let imageUrlString = article.urlToImage
        if !GlobalConstants.verifyUrl(urlString: imageUrlString) {
            cell.imgHeadlines.image = #imageLiteral(resourceName: "NoImage")
            return cell
        }
        else {
            cell.imgHeadlines.image = #imageLiteral(resourceName: "ImageComingSoon") // Image coming soon
        }
        
        // Download images in background thread asynchronously
        if let imageUrl = URL(string: imageUrlString!) {
            URLSession.shared.dataTask(with: URLRequest(url: imageUrl)) { (data, response, error) in
                if let data = data {
                    DispatchQueue.main.async {
                        cell.imgHeadlines.image = UIImage(data: data)
                    }
                } else {
                    DispatchQueue.main.async {
                        cell.imgHeadlines.image = #imageLiteral(resourceName: "ImageComingSoon")
                    }
                }
                }.resume()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: (width - 60)/2, height: 200) // 60: we are setting left and right inset.
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let storyboard = GlobalConstants.getMainStoryboardInstance()
        let controller = storyboard.instantiateViewController(withIdentifier: "DetailVcId") as! DetailViewController
        controller.newsModalObj = arrArticlesList[indexPath.row]
        
        self.navigationController?.pushViewController(controller, animated: true)
    }
}

