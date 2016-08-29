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
    
    func addPlace(location: CLLocation, notes: String?) {
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        LocationController.sharedController.reverseGeocoding(latitude, longitude: longitude) { (placemark) in
            guard let placemark = placemark, title = placemark.name, subThoroughfare = placemark.subThoroughfare, thoroughfare = placemark.thoroughfare, city = placemark.locality, state = placemark.administrativeArea, zip = placemark.postalCode else { return }
            
            let streetAddress = "\(subThoroughfare) \(thoroughfare)"
            
            let _ = Place(title: title, streetAddress: streetAddress, city: city, state: state, zipCode: zip, latitude: latitude, longitude: longitude, notes: notes)
            
            self.saveToPersistentStore()
        }
    }
    
    func updateNotesForPlace(place: Place, notes: String) {
        
        place.notes = notes
        
        saveToPersistentStore()
    }
    
    func deletePlace(place: Place) {
        
        moc.deleteObject(place)
        saveToPersistentStore()
    }
    
    func saveToPersistentStore() {
        
        do {
            try moc.save()
        } catch {
            print("Unable to save to managed object context.")
        }
    }
}













