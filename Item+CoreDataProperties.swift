//
//  Item+CoreDataProperties.swift
//  CoreDataFunS1
//
//  Created by Gina Sprint on 11/9/20.
//  Copyright © 2020 Gina Sprint. All rights reserved.
//
//

import Foundation
import CoreData


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item")
    }

    @NSManaged public var name: String?
    @NSManaged public var done: Bool
    @NSManaged public var parentCategory: Category?

}
