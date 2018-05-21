//
//  BookmarkModal.swift
//  ModalKuNewsApp
//
//  Created by Naveen kumar R on 21/05/18.
//  Copyright © 2018 HMD. All rights reserved.
//

import UIKit
import CoreData

class BookmarkModal: NSObject {

    var title : String?
    var urlToImage : String?
    var articleSourceName : String?
    var publishedAt : String?
    var articleDescription : String?
    var authorName : String?
    
    func checkWhetherThisNewsIsListedInBookmark(modalObj : NewsModal) -> Bool {
        guard let appDelegate = UIApplication .shared .delegate as? AppDelegate else {
            return false
        }
        
        var isPresent = false
        
        let managedContext = appDelegate .managedObjectContext
        let fetchRequest = NSFetchRequest<Bookmarks>(entityName: "Bookmarks")
        
        do {
            
            // 1 check whether it is already exist. Otherwise save it.
            let arrAllBookmarks = try managedContext .fetch(fetchRequest)
            for savedBookmark in arrAllBookmarks as [NSManagedObject] {
                print(savedBookmark)
                
                let savedNewsDateString = savedBookmark .value(forKey: "newsStringDate") as? String ?? ""
                let savedNewsSourceId = savedBookmark .value(forKey: "newsSourceName") as? String ?? ""
                
                if (savedNewsSourceId == modalObj.articleSourceName ?? "" && savedNewsDateString == modalObj.publishedAt ?? ""){
                    isPresent = true
                    break
                }
            }
            
            do {
                try managedContext .save()
            }
            catch _ as NSError {
            }
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return isPresent
    }
    
    func removeNewsFromBookmarkTable(modalObj : NewsModal) -> Bool {
        guard let appDelegate = UIApplication .shared .delegate as? AppDelegate else {
            return false
        }
        
        var isDeleted = false
        
        let managedContext = appDelegate .managedObjectContext
        let fetchRequest = NSFetchRequest<Bookmarks>(entityName: "Bookmarks")
        
        do {
            
            // 1 check whether it is already exist. Otherwise save it.
            let arrAllBookmarks = try managedContext .fetch(fetchRequest)
            for savedBookmark in arrAllBookmarks as [NSManagedObject] {
                print(savedBookmark)
                
                let savedNewsDateString = savedBookmark .value(forKey: "newsStringDate") as? String ?? ""
                let savedNewsSourceId = savedBookmark .value(forKey: "newsSourceName") as? String ?? ""
                
                if (savedNewsSourceId == modalObj.articleSourceName ?? "" && savedNewsDateString == modalObj.publishedAt ?? ""){
                    managedContext.delete(savedBookmark)
                    isDeleted = true
                    break
                }
            }
            
            do {
                try managedContext .save()
                isDeleted = true
            }
            catch _ as NSError {
                isDeleted = false
            }
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return isDeleted
    }
    
    func removeBookmarkThroughBookmarkList(modalObj : BookmarkModal) -> Bool {
        guard let appDelegate = UIApplication .shared .delegate as? AppDelegate else {
            return false
        }
        
        var isDeleted = false
        
        let managedContext = appDelegate .managedObjectContext
        let fetchRequest = NSFetchRequest<Bookmarks>(entityName: "Bookmarks")
        
        do {
            
            // 1 check whether it is already exist. Otherwise save it.
            let arrAllBookmarks = try managedContext .fetch(fetchRequest)
            for savedBookmark in arrAllBookmarks as [NSManagedObject] {
                print(savedBookmark)
                
                let savedNewsDateString = savedBookmark .value(forKey: "newsStringDate") as? String ?? ""
                let savedNewsSourceId = savedBookmark .value(forKey: "newsSourceName") as? String ?? ""
                
                if (savedNewsSourceId == modalObj.articleSourceName ?? "" && savedNewsDateString == modalObj.publishedAt ?? ""){
                    managedContext.delete(savedBookmark)
                    isDeleted = true
                    break
                }
            }
            
            do {
                try managedContext .save()
                isDeleted = true
            }
            catch _ as NSError {
                isDeleted = false
            }
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return isDeleted
    }
    
    func saveNewsInBookmarkTable(modalObj : NewsModal) -> Bool {
        guard let appDelegate = UIApplication .shared .delegate as? AppDelegate else {
            return false
        }
        
        var isSuccess = true
        
        let managedContext = appDelegate .managedObjectContext
        let fetchRequest = NSFetchRequest<Bookmarks>(entityName: "Bookmarks")
        
        do {
            
            // 1 check whether it is already exist. Otherwise save it.
            let arrAllBookmarks = try managedContext .fetch(fetchRequest)
            for savedBookmark in arrAllBookmarks as [NSManagedObject] {
                print(savedBookmark)
                
                let savedNewsDateString = savedBookmark .value(forKey: "newsStringDate") as? String ?? ""
                let savedNewsSourceId = savedBookmark .value(forKey: "newsSourceName") as? String ?? ""
                
                if (savedNewsSourceId == modalObj.articleSourceName ?? "" && savedNewsDateString == modalObj.publishedAt ?? ""){
                    isSuccess = false
                    break
                }
            }
            
            // 2 Save it if not exist
            if isSuccess {
                let entity = NSEntityDescription .entity(forEntityName: "Bookmarks",
                                                         in: managedContext)!
                
                let bookmark = NSManagedObject(entity: entity,
                                                insertInto: managedContext)
                
                bookmark .setValue(modalObj.title ?? "", forKeyPath: "newsTitle")
                bookmark .setValue(modalObj.urlToImage ?? "", forKeyPath: "newsImageUrl")
                bookmark .setValue(modalObj.publishedAt ?? "", forKeyPath: "newsStringDate")
                bookmark .setValue(modalObj.articleSourceName ?? "", forKeyPath: "newsSourceName")
                bookmark .setValue(modalObj.authorName, forKey: "newsAuthor")
                bookmark .setValue(modalObj.articleDescription, forKey: "newsDescription")
                
                do {
                    try managedContext .save()
                } catch let error as NSError {
                    print("Could not save. \(error), \(error.userInfo)")
                }
            }
            
            return isSuccess
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return false
    }
    
    func retriveAllListOfBookmarks() -> Array<BookmarkModal> {
        
        var arrBookmarkModalObj : Array<BookmarkModal> = []
        
        let appDelegate = UIApplication .shared .delegate as! AppDelegate
        
        let managedContext = appDelegate .managedObjectContext
        let fetchRequest = NSFetchRequest<Bookmarks>(entityName: "Bookmarks")
        
        do {
            
            // 1 check whether it is already exist. Otherwise save it.
            let arrAllBookmarks = try managedContext .fetch(fetchRequest)
            for savedBookmark in arrAllBookmarks as [NSManagedObject] {
                print(savedBookmark)
                
                let modalObj = BookmarkModal()
                
                modalObj.publishedAt = savedBookmark .value(forKey: "newsStringDate") as? String ?? ""
                modalObj.articleSourceName = savedBookmark .value(forKey: "newsSourceName") as? String ?? ""
                modalObj.title = savedBookmark .value(forKey: "newsTitle") as? String ?? ""
                modalObj.urlToImage = savedBookmark .value(forKey: "newsImageUrl") as? String ?? ""
                modalObj.authorName = savedBookmark .value(forKey: "newsAuthor") as? String ?? ""
                modalObj.articleDescription = savedBookmark .value(forKey: "newsDescription") as? String ?? ""
                
                arrBookmarkModalObj .append(modalObj)
            }
        }
        catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
        return arrBookmarkModalObj
    }
}
