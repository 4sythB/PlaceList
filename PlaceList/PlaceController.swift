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
    
    var region: MKCoordinateRegion?
    
    var places: [Place] {
        let request = NSFetchRequest(entityName: "Place")
        
        do {
            return try moc.executeFetchRequest(request) as? [Place] ?? []
        } catch {
            return []
        }
    }
    
    var sortedPlaces: [Place] {
        var sortedPlaces: [Place] = []
        
        guard let currentLocation = PlaceListViewController.locationManager.location else { return sortedPlaces }
        
        sortedPlaces = places.sort({ $0.0.clLocation?.distanceFromLocation(currentLocation) < $0.1.clLocation?.distanceFromLocation(currentLocation) })
        
        return sortedPlaces
    }
    
    var annotations: [MKAnnotation] {
        get {
            var annotations: [MKAnnotation] = []
            
            for place in places {
                
                let coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude)
                let annotation = MapPin(coordinate: coordinate, title: place.title, subtitle: "\(place.streetAddress), \(place.city)")
                
                annotations.append(annotation)
            }
            return annotations
        }
        set {
            
        }
    }
    
    // MARK: - Functions
    
    func addPlace(placemark: MKPlacemark, notes: String?) {
        
        let latitude = placemark.coordinate.latitude
        let longitude = placemark.coordinate.longitude
        
        guard let title = placemark.name, subThoroughfare = placemark.subThoroughfare, thoroughfare = placemark.thoroughfare, city = placemark.locality, state = placemark.administrativeArea, zipCode = placemark.postalCode else { return }
        
        let streetAddress = "\(subThoroughfare) \(thoroughfare)"
        
        let _ = Place(title: title, streetAddress: streetAddress, city: city, state: state, zipCode: zipCode, latitude: latitude, longitude: longitude, notes: notes)
        
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













