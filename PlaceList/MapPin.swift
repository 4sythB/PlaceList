//
//  MapPin.swift
//  PlaceList
//
//  Created by Brad on 8/30/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import Foundation
import MapKit

class MapPin : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var isSaved: Bool
    
    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String?, isSaved: Bool) {
        
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.isSaved = isSaved
    }
}