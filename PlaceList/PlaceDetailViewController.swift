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
    @IBOutlet weak var editDoneButton: UIBarButtonItem!
    
    var place: Place?
    var placemark: MKPlacemark?
    
    var mode: ButtonMode = .ViewMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
    }
    
    func setUpView() {
        
        guard let placemark = placemark, place = place else { return }
        
        let title = place.title, streetAddress = place.streetAddress, city = place.city, state = place.state, zip = place.zipCode
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        
        navigationItem.title = title
        
        placeTitleLabel.text = title
        streetAddressLabel.text = streetAddress
        cityStateZipLabel.text = "\(city), \(state) \(zip)"
        
        editDoneButton.title = "Edit"
        editDoneButton.style = .Plain
    }
    
    // MARK: - View mode
    
    enum ButtonMode {
        case ViewMode
        case EditMode
    }
    
    func goToEditMode() {
        
        editDoneButton.title = "Done"
        editDoneButton.style = .Done
        mode = .EditMode
        
        notesTextView.editable = true
    }
    
    func goToViewMode() {
        
        editDoneButton.title = "Edit"
        editDoneButton.style = .Plain
        mode = .ViewMode
        
        notesTextView.editable = false
    }
    
    // MARK: - Action
    
    @IBAction func viewModeButtonTapped(sender: AnyObject) {
        
        switch mode {
        case .ViewMode:
            goToEditMode()
            return
            
        case .EditMode:
            goToViewMode()
            return
        }
    }
    
    // MARK: - Navigation
    
    /*
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     
     }
     */
}









