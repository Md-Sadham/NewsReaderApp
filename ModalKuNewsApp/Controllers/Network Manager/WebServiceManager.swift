//
//  WebServiceManager.swift
//  MVCSampleApp
//
//  Created by Sadham on 29/04/2018.
//  Copyright © 2018 Sadham. All rights reserved.
//

import UIKit

class WebServiceManager: NSObject {

    // create singleton instance
    class var webServiceManagerSharedInstance : WebServiceManager {
        struct Singleton {
            static let instance = WebServiceManager()
        }
        return Singleton .instance
    }
    
    func getRequestedArticles (newsModalObj : NewsModal, endpoint: String, userInput : String,
                          Success: @escaping ((_ newsModalSuccessObj : Array<NewsModal>) -> Void),
                          Failure: @escaping ((_ failureError : String) -> Void))
    {
        let requestUrl = GlobalConstants.BASE_URL + endpoint + GlobalConstants.API_KEY + userInput
        print("Req url: ", requestUrl)
        
        let connManagerObj = ConnectionManager.connectionManagerSharedInstance
        connManagerObj.requestGetServiceAPI(urlString: requestUrl, onSuccess: { (responseCode : Int, serverResponse : Any) in
            let response = serverResponse as! Dictionary<String, Any>
            if !response.isEmpty {
                
                let articleModelObj =  NewsModal()
                articleModelObj.status = response["status"] as? String
                
                if(response["status"] as? String == "ok"){
                    let arrArticles = articleModelObj.parseTopHeadlinesResponse(articleList: response["articles"] as! Array<Any>)
                    Success(arrArticles)
                }
                else {
                    // status == "error"
                    articleModelObj.message = response["message"] as? String
                    
                    Failure(articleModelObj.message ?? "Something went wrong when contacting the news server")
                }
            }
            
        }, onFailure: { (error : String) in
            Failure(error)
        })
    }
    
    func getRequestSourcesList (sourceModalObj : SourcesModal, userInput : String,
                               Success: @escaping ((_ sourceModalSuccessObj : Array<SourcesModal>) -> Void),
                               Failure: @escaping ((_ failureError : String) -> Void))
    {
        let requestUrl = GlobalConstants.BASE_URL + "sources" + GlobalConstants.API_KEY + userInput
        print("Req url: ", requestUrl)
        
        let connManagerObj = ConnectionManager.connectionManagerSharedInstance
        connManagerObj.requestGetServiceAPI(urlString: requestUrl, onSuccess: { (responseCode : Int, serverResponse : Any) in
            let response = serverResponse as! Dictionary<String, Any>
            if !response.isEmpty {
                
                let sourceModelObj =  SourcesModal()
                sourceModelObj.status = response["status"] as? String
                
                if(response["status"] as? String == "ok"){
                    let arrSources = sourceModelObj.parseSourcesResponse(sourceList: response["sources"] as! Array<Any>)
                    Success(arrSources)
                }
                else {
                    // status == "error"
                    sourceModelObj.message = response["message"] as? String
                    
                    Failure(sourceModelObj.message ?? "Something went wrong when contacting the news server")
                }
            }
            
        }, onFailure: { (error : String) in
            Failure(error)
        })
    }
}






