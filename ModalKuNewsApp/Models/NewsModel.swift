//
//  NewsModel.swift
//  ModalKuNewsApp
//
//  Created by Naveen kumar R on 17/05/18.
//  Copyright © 2018 HMD. All rights reserved.
//

import Foundation

class NewsModal : NSObject {
    // Response: status, totalresults, articles, source, author, title, description, url, urlToImage, publishedAt
    // Response: sources, status, id, name, desription, url, category, language, country
    
    // Status
    var status : String? // ok , error
    
    // Status : error
    var code: String?
    var message : String?
    
    // Result count
    var totalResults : Int?
    
    // All news are within below array
    var arrArticles : Array<Any>?
    
    // arrArticles : Keys & its values
    // Array source and its keys
    var dictArticleSource : Dictionary<String,Any>?
    var articleSourceId : String?
    var articleSourceName : String?
    
    // arrArticles : other keys & values
    var authorName : String?
    var title : String?
    var articleDescription : String?
    var url : String?
    var urlToImage : String?
    var publishedAt : String?
    
    // Specifically for Everything tab
    var language : String?
    var sortBy : String?
    var userSeachKeyword : String?
    
    func parseTopHeadlinesResponse(articleList : Array<Any>) -> Array<NewsModal> {
        
        var arrArticles : Array<NewsModal> = []
        
        if articleList.count > 0
        {
            for article in 0...articleList.count-1
            {
                let articleObj = NewsModal()
                
                let dictArticleObj  : [String:Any] = articleList[article] as! [String : Any]
                
                articleObj.dictArticleSource = dictArticleObj["source"] as? Dictionary<String, Any>
                articleObj.articleSourceName = articleObj.dictArticleSource?["name"] as? String
                articleObj.articleSourceId = articleObj.dictArticleSource?["id"] as? String // No need
                
                articleObj.authorName =  dictArticleObj["author"] as? String
                articleObj.title = dictArticleObj["title"] as? String
                articleObj.articleDescription = dictArticleObj["description"] as? String
                articleObj.url = dictArticleObj["url"] as? String
                articleObj.urlToImage = dictArticleObj["urlToImage"] as? String
                articleObj.publishedAt = dictArticleObj["publishedAt"] as? String
                
                arrArticles.append(articleObj)
            }
        }
        return arrArticles
    }
}
