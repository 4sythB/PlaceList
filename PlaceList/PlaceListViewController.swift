//
//  PlaceListViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class PlaceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    static let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    
    var mapIsCentered: Bool = true {
        didSet {
            if mapIsCentered == true {
                let image = UIImage(named: "NearMeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
                currentLocationButton.setImage(image, forState: .Normal)
                currentLocationButton.tintColor = UIColor.init(red: 0.02, green: 0.49, blue: 1.00, alpha: 1.0)
            } else if mapIsCentered == false {
                let image = UIImage(named: "NearMe")?.imageWithRenderingMode(.AlwaysTemplate)
                currentLocationButton.setImage(image, forState: .Normal)
                currentLocationButton.tintColor = UIColor.init(red: 0.02, green: 0.49, blue: 1.00, alpha: 1.0)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PlaceListViewController.locationManager.delegate = self
        PlaceListViewController.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        PlaceListViewController.locationManager.requestWhenInUseAuthorization()
        PlaceListViewController.locationManager.requestLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        tableView.reloadData()
        mapView.removeAnnotations(PlaceController.sharedController.annotations)
        mapView.addAnnotations(PlaceController.sharedController.annotations)
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaceController.sharedController.sortedPlaces.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("placeListCell", forIndexPath: indexPath)
        
        let place = PlaceController.sharedController.sortedPlaces[indexPath.row]
        
        cell.textLabel?.text = place.title
        cell.detailTextLabel?.text = "\(place.city), \(place.state)"
        
        return cell
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let place = PlaceController.sharedController.sortedPlaces[indexPath.row]
            
            let annotations = mapView.annotations
            for annotation in annotations {
                mapView.removeAnnotation(annotation)
            }
            
            PlaceController.sharedController.deletePlace(place)
            
            mapView.addAnnotations(PlaceController.sharedController.annotations)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    // MARK: - Map Delegate
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        mapIsCentered = false
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let place = PlaceController.sharedController.sortedPlaces[indexPath.row]
        
        let coordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude)
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        
        if segue.identifier == "toDetailSegue" {
            guard let destinationVC = segue.destinationViewController as? PlaceDetailViewController else { return }
            destinationVC.place = place
            destinationVC.placemark = placemark
        }
    }
    
    // MARK: - Action
    
    @IBAction func currentLocationButtonTapped(sender: AnyObject) {
        
        if let location = PlaceListViewController.locationManager.location {
            let span = mapView.region.span
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            PlaceController.sharedController.region = region
        }
        mapIsCentered = true
    }
}

// MARK: - Location manager delegate

extension PlaceListViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            PlaceListViewController.locationManager.requestLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if let location = locations.first {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: false)
            PlaceController.sharedController.region = region
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error: \(error.localizedDescription)")
    }
}









