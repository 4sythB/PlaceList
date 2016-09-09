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
    @IBOutlet weak var mapViewHeightConstraint: NSLayoutConstraint!
    
    static let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    
    let mapButton = UIButton()
    
    var mode: MapViewMode = .HalfScreenMode
    
    var regionSet: Bool = false
    
    enum MapViewMode {
        case FullScreenMode
        case HalfScreenMode
    }
    
    var mapIsCentered: Bool = true {
        didSet {
            if mapIsCentered == true {
                let image = UIImage(named: "NearMeFilled")?.imageWithRenderingMode(.AlwaysTemplate)
                currentLocationButton.setImage(image, forState: .Normal)
                currentLocationButton.tintColor = UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1.0)
            } else if mapIsCentered == false {
                let image = UIImage(named: "NearMe")?.imageWithRenderingMode(.AlwaysTemplate)
                currentLocationButton.setImage(image, forState: .Normal)
                currentLocationButton.tintColor = UIColor(red: 41/255, green: 128/255, blue: 185/255, alpha: 1.0)
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
        
        setUpButton()
        
        tableView.reloadData()
        mapView.removeAnnotations(PlaceController.sharedController.annotations)
        mapView.addAnnotations(PlaceController.sharedController.annotations)
        
        guard let location = PlaceListViewController.locationManager.location else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        PlaceController.sharedController.region = region
    }
    
    // MARK: - Map Button
    
    func setUpButton() {
        
        let image = UIImage(named: "Map")?.imageWithRenderingMode(.AlwaysTemplate)
        mapButton.frame = CGRectMake(0, 0, 23, 23) //won't work if you don't set frame
        mapButton.setImage(image, forState: .Normal)
        mapButton.tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        mapButton.addTarget(self, action: #selector(showMapView), forControlEvents: .TouchUpInside)
        
        let barButton = UIBarButtonItem()
        barButton.customView = mapButton
        self.navigationItem.leftBarButtonItem = barButton
    }
    
    func showMapView() {
        
        switch mode {
        case .HalfScreenMode:
            mapViewHeightConstraint.constant = 275
            
            
            mode = .FullScreenMode
            return
            
        case .FullScreenMode:
            let viewHeight = self.view.frame.size.height
            mapViewHeightConstraint.constant = viewHeight
            
            
            mode = .HalfScreenMode
            return
        }
        
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PlaceController.sharedController.sortedPlaces.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("placeListCell", forIndexPath: indexPath) as? PlaceListTableViewCell else { return UITableViewCell() }
        
        let place = PlaceController.sharedController.sortedPlaces[indexPath.row]
        
        cell.updateWithPlace(place)
        
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
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        header.textLabel?.font = UIFont(name: "avenir-medium", size: 16)!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Saved Places"
    }
    
    // MARK: - Map Delegate
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        mapIsCentered = false
    }
    
    // MARK: - Navigation
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        
    }
    
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
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
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
        
        if regionSet == false {
            guard let location = locations.first else { return }
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: false)
            PlaceController.sharedController.region = region
            regionSet = true
        }
        self.tableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        
        print("Error: \(error.localizedDescription)")
    }
}









