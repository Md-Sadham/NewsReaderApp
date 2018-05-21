//
//  GlobalConstants.swift
//  MVCSampleApp
//
//  Created by Sadham on 29/04/2018.
//  Copyright © 2018 Sadham. All rights reserved.
//

import UIKit

class GlobalConstants: NSObject {
    
    // MARK: - Static Variables
    static let appDelegateRef : AppDelegate = UIApplication.shared.delegate as! AppDelegate
    static let API_KEY = "YOUR_API_KEY"
    static let BASE_URL = "https://newsapi.org/v2/"
    
    // MARK: - Enums
    enum UIUserInterfaceIdiom : Int
    {
        case Unspecified
        case Phone
        case Pad
    }
    
    // MARK: - Struct
    struct ScreenSize
    {
        static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
        static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
        static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
        static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    }
    
    struct DeviceType
    {
        static let IS_IPHONE_4_OR_LESS  = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH < 568.0
        static let IS_IPHONE_5          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 568.0
        static let IS_IPHONE_6          = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 667.0
        static let IS_IPHONE_6P         = UIDevice.current.userInterfaceIdiom == .phone && ScreenSize.SCREEN_MAX_LENGTH == 736.0
        static let IS_IPAD              = UIDevice.current.userInterfaceIdiom == .pad && ScreenSize.SCREEN_MAX_LENGTH == 1024
    }
    
    struct Version{
        static let SYS_VERSION_FLOAT = (UIDevice.current.systemVersion as NSString).floatValue
        static let iOS7 = (Version.SYS_VERSION_FLOAT < 8.0 && Version.SYS_VERSION_FLOAT >= 7.0)
        static let iOS8 = (Version.SYS_VERSION_FLOAT >= 8.0 && Version.SYS_VERSION_FLOAT < 9.0)
        static let iOS9 = (Version.SYS_VERSION_FLOAT >= 9.0 && Version.SYS_VERSION_FLOAT < 10.0)
    }
    
    // MARK: - Functions
    class func readProductNameFromPlist() -> String {
        return Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
    }
    
    class func getMainStoryboardInstance() -> UIStoryboard
    {
        let userStoryboard = UIStoryboard(name: "Main", bundle: nil)
        return userStoryboard
    }
    
    class func getCustomPickerInstance() -> CustomPicker
    {
        let storyboard = GlobalConstants.getMainStoryboardInstance()
        let customPickerObj = (storyboard.instantiateViewController(withIdentifier: "CustomPickerStoryboard")) as! CustomPicker
        return customPickerObj
    }
    
    class func filterSpace(removeSpace : String) -> String
    {
        let trimmedString = removeSpace.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmedString
    }
    
    class func showSuccessFailureAlertWithDismissHandler(title : String, message: String, okTitle: String, controller : UIViewController, alertDismissed:@escaping ((_ okPressed: Bool)->Void))
    {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let alertOKButton = UIAlertAction(title: okTitle, style: UIAlertActionStyle.default, handler: { action in
            print("Alert Dismissed")
            alertDismissed(true)
        })
        alert.addAction(alertOKButton)
        controller.present(alert, animated: true, completion: {
            print("Alert presented success");
        })
    }
    
    // Verify whether string is url or not
    class func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    class func urlRequestParamEncoding(reqParam : String) -> String {
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: ".-_")
        let searchKeywordWithEncoded = reqParam.addingPercentEncoding(withAllowedCharacters: allowed)
        
        return searchKeywordWithEncoded!
    }
}


