//
//  PlaceController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import CoreData
import MapKit

class PlaceController {
    
    static let sharedController = PlaceController()
    let moc = Stack.sharedStack.managedObjectContext
    
    func addPlace(location: CLLocation) {
        
        
    }
    
    func saveToPersistentStore() {
        
        do {
            try moc.save()
        } catch {
            print("Unable to save to managed object context.")
        }
    }
}