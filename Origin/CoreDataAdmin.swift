//
//  CoreDataAdmin.swift
//  Origin
//
//  Created by Gen on 2016/11/26.
//  Copyright © 2016年 Gen. All rights reserved.
//

import UIKit
import Foundation
import MediaPlayer
import AVFoundation
import CoreData

class CoreDataAdmin: NSObject, NSFetchedResultsControllerDelegate{
    
    weak var viewController :MainViewController?
    // 全削除
    func deleteAll(entityName: String) {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext:NSManagedObjectContext = appDelegate.managedObjectContext
        let fetchReqest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        fetchReqest.returnsObjectsAsFaults = false
        
        do
        {
            let results = try managedObjectContext.fetch(fetchReqest)
            for managedObject in results
            {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedObjectContext.delete(managedObjectData)
            }
            
        } catch {
            
        }
    }
    
    
    func defaultSetLibrary() {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        for song in musicplayer.playlist  {
            let entity = NSEntityDescription.entity(forEntityName: "Library", in: managedObjectContext)
            
            let record = Library(entity: entity!, insertInto: managedObjectContext)
            
            record.id = "\(song.persistentID)"
            record.rating = 3
            record.isKnown = true
        }
        do{
            try managedObjectContext.save()
        }catch{
        }
    }
    
    func rating(of song: MPMediaItem){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        let fetchReqest = NSFetchRequest<NSFetchRequestResult>(entityName: "Library")
        
        let predict = NSPredicate(format: "id = %@", "\(song.persistentID)")
        fetchReqest.predicate = predict
        
        do {
            let results = try managedObjectContext.fetch(fetchReqest)
            let result = results[0] as! Library
            viewController?.ratingBar.rating = result.rating
        }catch{
        }
    }
    
    func changeRatingOfLibrary(song:MPMediaItem, rating: Double) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        let fetchLibrary = NSFetchRequest<NSFetchRequestResult>(entityName: "Library")
        let predict = NSPredicate(format: "id = %@", "\(song.persistentID)")
        print(predict)
        fetchLibrary.predicate = predict
        
        do {
            let results = try managedObjectContext.fetch(fetchLibrary)
            let result = results[0] as! Library
            result.rating = rating
            
        }catch{
        }
    }
    
    
    func appendHistory(song: MPMediaItem, rating: Double, isKnown: Bool=true) {
        let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext
        
        let entity = NSEntityDescription.entity(forEntityName: "History", in: managedObjectContext)
        
        let record = History(entity: entity!, insertInto: managedObjectContext)
        
        record.id = "\(song.persistentID)"
        record.title = song.title ?? "unknown"
        record.artist = song.artist ?? "unknown"
        record.album = song.albumTitle ?? "unknown"
        record.rating = rating
        record.isKnown = isKnown
        record.date = NSDate()
        
        do{
            try managedObjectContext.save()
        }catch{
        }
    }

}
