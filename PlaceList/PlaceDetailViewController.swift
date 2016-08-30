//
//  PlaceDetailViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class PlaceDetailViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var cityStateZipLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    var place: Place?
    var placemark: MKPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    func setUpView() {
        
        guard let placemark = placemark, place = place else { return }
        
        let title = place.title, streetAddress = place.streetAddress, city = place.city, state = place.state, zip = place.zipCode
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        
        placeTitleLabel.text = title
        streetAddressLabel.text = streetAddress
        cityStateZipLabel.text = "\(city), \(state) \(zip)"
    }
    
    
    // MARK: - Navigation
    
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
     }
     */
}
