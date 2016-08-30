//
//  PlaceListViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class PlaceListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    static let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        PlaceListViewController.locationManager.delegate = self
        PlaceListViewController.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        PlaceListViewController.locationManager.requestWhenInUseAuthorization()
        PlaceListViewController.locationManager.requestLocation()
        
        SearchTableViewController.region = mapView.region
    }
    
    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaceController.sharedController.places.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("placeListCell", forIndexPath: indexPath)
        
        let place = PlaceController.sharedController.places[indexPath.row]
        
        cell.textLabel?.text = place.title
        cell.detailTextLabel?.text = "\(place.city), \(place.state)"

        return cell
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let place = PlaceController.sharedController.places[indexPath.row]
        
        if segue.identifier == "toDetailSegue" {
            guard let destinationVC = segue.destinationViewController as? PlaceDetailViewController else { return }
            destinationVC.place = place
        }
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
            mapView.setRegion(region, animated: true)
        }
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error: \(error.localizedDescription)")
    }
}








