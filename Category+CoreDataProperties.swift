//
//  Category+CoreDataProperties.swift
//  CoreDataFunS1
//
//  Created by Gina Sprint on 11/4/20.
//  Copyright © 2020 Gina Sprint. All rights reserved.
//
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var name: String?

}
