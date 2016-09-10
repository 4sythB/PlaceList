//
//  Place.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation
import MapKit

class Place: NSManagedObject {
    
    convenience init?(title: String, streetAddress: String?, city: String?, state: String?, zipCode: String?, latitude: Double, longitude: Double, notes: String?, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Place", inManagedObjectContext: context) else {
            fatalError("Unable to initialize entity")
        }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.title = title
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.latitude = latitude
        self.longitude = longitude
        self.notes = notes
    }
    
    var clLocation: CLLocation? {
        return CLLocation(latitude: latitude, longitude: longitude)
    }
}
