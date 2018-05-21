//
//  ConnectionManager.swift
//  MVCSampleApp
//
//  Created by Sadham on 29/04/2018.
//  Copyright © 2018 Sadham. All rights reserved.
//

import UIKit

class ConnectionManager: NSObject {
    typealias successCompletionHandler = (_ statusCode: Int, _ serverResponse: Any) -> Void
    typealias failureCompletionHandler = (_ error : String) -> Void
    
    class var connectionManagerSharedInstance : ConnectionManager {
        struct Singleton {
            static let instance = ConnectionManager()
        }
        return Singleton .instance
    }
    
    func requestGetServiceAPI(urlString : String, onSuccess: @escaping successCompletionHandler, onFailure: @escaping failureCompletionHandler) {
        
        print("===============================GET REQUESTING API======================================================")
        print("URL String =\(urlString)")
        
        // URL Request
        let requestUrl = URL(string: urlString)
        var urlRequest = URLRequest(url: requestUrl!)
        urlRequest.timeoutInterval = 60
        urlRequest.cachePolicy = .reloadIgnoringCacheData
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-type")
        
        // URL Session
        let urlSessionConfig = URLSessionConfiguration.default
        let urlSession = URLSession(configuration: urlSessionConfig)
        
        // Data task
        if Reachability.isConnectedToNetwork() == true {
            let task = urlSession.dataTask(with: urlRequest, completionHandler: {
                (data, response, error) in
                
                if error != nil
                {
                    print("Error  ==",error!.localizedDescription);
                    onFailure(error!.localizedDescription)
                }
                else
                {
                    let httpResponse = response as! HTTPURLResponse
                    let statusCode = httpResponse.statusCode
                    
                    do {
                        let jsonResponse = try JSONSerialization.jsonObject(with: data!, options: .allowFragments)
                        
                        let response = jsonResponse as! Dictionary<String,Any>
                        guard !response.isEmpty else {
                            return onFailure("No Responses has been received!")
                        }
                        
                        // Success defines only the user request is completed. Its not whether response have expected result
                        onSuccess(statusCode, response)
                    }
                    catch {
                        onFailure("Response Format Error!")
                    }
                }
            })
            task.resume();
        }
        else {
            onFailure("Please check your internet connection and try again!")
        }
    }
}
