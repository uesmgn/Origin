//
//  Library+CoreDataProperties.swift
//  Origin
//
//  Created by Gen on 2016/11/26.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import MediaPlayer
import CoreData


extension Library {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Library> {
        return NSFetchRequest<Library>(entityName: "Library");
    }

    @NSManaged public var rating: Double
    @NSManaged public var id: String?
    @NSManaged public var isKnown: Bool

}
