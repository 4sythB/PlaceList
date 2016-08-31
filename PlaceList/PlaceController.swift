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
    
    var places: [Place] {
        
        let request = NSFetchRequest(entityName: "Place")
        
        do {
            return try moc.executeFetchRequest(request) as? [Place] ?? []
        } catch {
            return []
        }
    }
    
    var annotations: [MKAnnotation] {
        
        var annotations: [MKAnnotation] = []
        
        for place in places {
            
            let coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude)
            
            let annotation = MapPin(coordinate: coordinate, title: place.title, subtitle: "\(place.streetAddress), \(place.city)")
            
            annotations.append(annotation)
        }
        
        return annotations
    }
    
    func addPlace(location: MKPlacemark, notes: String?) {
        
        let placemark = location
        
        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        guard let title = placemark.name, subThoroughfare = placemark.subThoroughfare, thoroughfare = placemark.thoroughfare, city = placemark.locality, state = placemark.administrativeArea, zip = placemark.postalCode else { return }
        
        let streetAddress = "\(subThoroughfare) \(thoroughfare)"
        
        let _ = Place(title: title, streetAddress: streetAddress, city: city, state: state, zipCode: zip, latitude: latitude, longitude: longitude, notes: notes)
        
        self.saveToPersistentStore()
    }
    
    func updateNotesForPlace(place: Place, notes: String?) {
        
        if let index = places.indexOf(place) {
            places[index].notes = notes
            saveToPersistentStore()
        }
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
    
    func getById(id: NSManagedObjectID) -> Place? {
        return moc.objectWithID(id) as? Place
    }
}













