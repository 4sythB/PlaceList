//
//  Place.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import CoreData


class Place: NSManagedObject {

    convenience init?(title: String, streetAddress: String, city: String, state: String, zipCode: String, location: NSData, notes: String?, context: NSManagedObjectContext = Stack.sharedStack.managedObjectContext) {
        
        guard let entity = NSEntityDescription.entityForName("Place", inManagedObjectContext: context) else {
            fatalError("Unable to initialize entity")
        }
        
        self.init(entity: entity, insertIntoManagedObjectContext: context)
        
        self.title = title
        self.streetAddress = streetAddress
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.location = location
        self.notes = notes
    }
}
