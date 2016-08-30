//
//  DetailContainerViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class DetailContainerViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var cityStateZipLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    
    var place: MKPlacemark? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpContainerView()
    }
    
    func setUpContainerView() {
        
        guard let placemark = place, title = placemark.name, subThoroughfare = placemark.subThoroughfare, thoroughfare = placemark.thoroughfare, city = placemark.locality, state = placemark.administrativeArea, zip = placemark.postalCode else { return }
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        
        let streetAddress = "\(subThoroughfare) \(thoroughfare)"
        
        placeTitleLabel.text = title
        streetAddressLabel.text = streetAddress
        cityStateZipLabel.text = "\(city), \(state) \(zip)"
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}






