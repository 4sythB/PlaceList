//
//  MapViewController.swift
//  PlaceList
//
//  Created by Brad on 9/7/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    
    var resultsSearchController: UISearchController? = nil
    
    var region = PlaceController.sharedController.region
    
    var annotation: MKAnnotation?
    
    static var matchingItems: [MKMapItem] = []
    
    var item: MKMapItem? {
        didSet {
            guard let item = item else { return }
            
            let coordinates = CLLocationCoordinate2DMake(item.placemark.coordinate.latitude, item.placemark.coordinate.longitude)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            let region = MKCoordinateRegion(center: coordinates, span: span)
            mapView.setRegion(region, animated: true)
            
            mapView.addAnnotation(item.placemark)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mapRegion = region {
            mapView.setRegion(mapRegion, animated: true)
        }
        
        setupSearchController()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        guard let item = item else { return }
        mapView.addAnnotation(item.placemark)
    }
    
    // MARK: - Long press gesture action
    
    @IBAction func longPressAction(sender: UILongPressGestureRecognizer) {
        
        if sender.state == .Began {
            let location = sender.locationInView(mapView)
            let coordinate = mapView.convertPoint(location,toCoordinateFromView: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "New Location"
            annotation.subtitle = "Tap to add location"
            
            self.annotation = annotation
            
            mapView.removeAnnotations(mapView.annotations)
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
        
        pinView.canShowCallout = true
        pinView.animatesDrop = true
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        guard let annotation = self.annotation else { return }
        
        let seconds = 0.5
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per second
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            mapView.selectAnnotation(annotation, animated: false)
        })
    }
    
    // MARK: - Search
    
    func setupSearchController() {
        
        let locationSearchTable = storyboard?.instantiateViewControllerWithIdentifier("ResultsTableViewController") as? ResultsTableViewController
        
        resultsSearchController = UISearchController(searchResultsController: locationSearchTable)
        
        guard let resultsSearchController = resultsSearchController else { return }
        
        resultsSearchController.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultsSearchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.searchBarStyle = .Default
        navigationItem.titleView = resultsSearchController.searchBar
        
        resultsSearchController.hidesNavigationBarDuringPresentation = false
        resultsSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    // MARK: - Map Delegate
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        PlaceController.sharedController.region = mapView.region
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









