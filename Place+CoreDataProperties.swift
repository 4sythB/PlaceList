//
//  Place+CoreDataProperties.swift
//  PlaceList
//
//  Created by Brad on 9/2/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData
import CoreLocation

extension Place {

    @NSManaged var city: String
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var notes: String?
    @NSManaged var state: String
    @NSManaged var streetAddress: String
    @NSManaged var title: String
    @NSManaged var zipCode: String

    var clLocation: CLLocation? {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
