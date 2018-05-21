//
//  SourcesModal.swift
//  ModalKuNewsApp
//
//  Created by Naveen kumar R on 20/05/18.
//  Copyright © 2018 HMD. All rights reserved.
//

import UIKit

class SourcesModal: NSObject {

    // Status
    var status : String? // ok , error
    
    // Status : error
    var code: String?
    var message : String?
    
    // arrArticles : Keys & its values
    // Array source and its keys
    var articleSourceId : String?
    var articleSourceName : String?
    var articleDescription : String?
    var url : String?
    var category : String?
    var language : String?
    var country : String?
    
    func parseSourcesResponse(sourceList : Array<Any>) -> Array<SourcesModal> {
        
        var arrSources : Array<SourcesModal> = []
        
        if sourceList.count > 0
        {
            for source in 0...sourceList.count-1
            {
                let sourceObj = SourcesModal()
                
                let dictSourceObj  : [String:Any] = sourceList[source] as! [String : Any]
                
                sourceObj.articleSourceId = dictSourceObj["id"] as? String
                sourceObj.articleSourceName = dictSourceObj["name"] as? String
                sourceObj.articleDescription = dictSourceObj["description"] as? String
                sourceObj.url = dictSourceObj["url"] as? String
                sourceObj.category = dictSourceObj["category"] as? String
                sourceObj.language = dictSourceObj["urlToImage"] as? String
                sourceObj.country = dictSourceObj["publishedAt"] as? String
                
                arrSources.append(sourceObj)
            }
        }
        return arrSources
    }
}
