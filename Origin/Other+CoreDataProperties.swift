//
//  Other+CoreDataProperties.swift
//  Origin
//
//  Created by Gen on 2016/11/26.
//  Copyright © 2016年 Gen. All rights reserved.
//

import Foundation
import CoreData


extension Other {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Other> {
        return NSFetchRequest<Other>(entityName: "Other");
    }

    @NSManaged public var id: String?
    @NSManaged public var isKnown: Bool
    @NSManaged public var rating: Double

}
