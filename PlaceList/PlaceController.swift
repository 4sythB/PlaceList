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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


class PlaceController {
    
    static let sharedController = PlaceController()
    let moc = Stack.sharedStack.managedObjectContext
    
    var region: MKCoordinateRegion?
    
    var places: [Place] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Place")
        let sortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        request.sortDescriptors = [sortDescriptor]
        
        do {
            return try moc.fetch(request) as? [Place] ?? []
        } catch {
            return []
        }
    }
    
    var sortedPlaces: [Place] {
        var sortedPlaces: [Place] = []
        
        guard let currentLocation = PlaceListViewController.locationManager.location else { return sortedPlaces }
        
        sortedPlaces = places.sorted(by: { $0.0.clLocation?.distance(from: currentLocation) < $0.1.clLocation?.distance(from: currentLocation) })
        
        return sortedPlaces
    }
    
    var annotations: [MKAnnotation] {
        var annotations: [MKAnnotation] = []
        
        for place in places {
            
            let coordinate = CLLocationCoordinate2DMake(place.latitude, place.longitude)
            
            if place.streetAddress == nil && place.city == nil {
                let annotation = MapPin(coordinate: coordinate, title: place.title, subtitle: nil, isSaved: true)
                annotations.append(annotation)
            } else if place.streetAddress == nil && place.city != nil {
                guard let city = place.city else { return [] }
                let annotation = MapPin(coordinate: coordinate, title: place.title, subtitle: city, isSaved: true)
                annotations.append(annotation)
            } else if place.streetAddress != nil && place.city != nil {
                guard let streetAddress = place.streetAddress, let city = place.city else { return [] }
                let annotation = MapPin(coordinate: coordinate, title: place.title, subtitle: "\(streetAddress), \(city)", isSaved: true)
                annotations.append(annotation)
            }
        }
        return annotations
    }
    
    // MARK: - Functions
    
    func addPlace(_ placemark: MKPlacemark, notes: String?) {
        
        let latitude = placemark.coordinate.latitude
        let longitude = placemark.coordinate.longitude
        
        guard let title = placemark.name else { return }
        
        if let subThoroughfare = placemark.subThoroughfare, let thoroughfare = placemark.thoroughfare {
            let streetAddress = "\(subThoroughfare) \(thoroughfare)"
            
            if let city = placemark.locality, let state = placemark.administrativeArea, let zipCode = placemark.postalCode {
                let _ = Place(title: title, streetAddress: streetAddress, city: city, state: state, zipCode: zipCode, latitude: latitude, longitude: longitude, notes: notes)
                saveToPersistentStore()
            } else {
                let _ = Place(title: title, streetAddress: streetAddress, city: nil, state: nil, zipCode: nil, latitude: latitude, longitude: longitude, notes: notes)
                saveToPersistentStore()
            }
        } else {
            if let city = placemark.locality, let state = placemark.administrativeArea, let zipCode = placemark.postalCode {
                let _ = Place(title: title, streetAddress: nil, city: city, state: state, zipCode: zipCode, latitude: latitude, longitude: longitude, notes: notes)
                saveToPersistentStore()
            } else {
                let _ = Place(title: title, streetAddress: nil, city: nil, state: nil, zipCode: nil, latitude: latitude, longitude: longitude, notes: notes)
                saveToPersistentStore()
            }
        }
    }
    
    func updateNotesForPlace(_ place: Place, notes: String?) {
        
        if let index = places.index(of: place) {
            places[index].notes = notes
            saveToPersistentStore()
        }
    }
    
    func deletePlace(_ place: Place) {
        
        moc.delete(place)
        saveToPersistentStore()
    }
    
    func saveToPersistentStore() {
        
        do {
            try moc.save()
        } catch {
            print("Unable to save to managed object context.")
        }
    }
    
    func getById(_ id: NSManagedObjectID) -> Place? {
        return moc.object(with: id) as? Place
    }
}













