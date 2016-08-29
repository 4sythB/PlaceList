//
//  Place+CoreDataProperties.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Place {

    @NSManaged var title: String
    @NSManaged var streetAddress: String
    @NSManaged var city: String
    @NSManaged var state: String
    @NSManaged var zipCode: String
    @NSManaged var location: NSData
    @NSManaged var notes: String?

}
