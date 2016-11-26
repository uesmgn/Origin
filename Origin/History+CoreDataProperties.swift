//
//  History+CoreDataProperties.swift
//  Origin
//
//  Created by Gen on 2016/11/27.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import CoreData


extension History {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<History> {
        return NSFetchRequest<History>(entityName: "History");
    }

    @NSManaged public var id: String?
    @NSManaged public var rating: Double
    @NSManaged public var title: String?
    @NSManaged public var artist: String?
    @NSManaged public var album: String?
    @NSManaged public var isKnown: Bool

}
