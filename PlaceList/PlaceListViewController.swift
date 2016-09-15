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
    @IBOutlet weak var currentLocationButton: UIButton!
    @IBOutlet weak var bottomTableViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var constraintBetweenMapAndTableView: NSLayoutConstraint!
    @IBOutlet weak var bottomMapToViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var mapSizeButtonImageView: UIImageView!
    @IBOutlet weak var mapSizeButton: UIButton!
    @IBOutlet weak var currentLocationButtonImageView: UIImageView!
    
    static let locationManager = CLLocationManager()
    
    var resultSearchController: UISearchController? = nil
    
    let settingsButton = UIButton()
    
    var droppedPinAnnotation: MKAnnotation?
    var droppedPinPlacemark: MKPlacemark?
    
    var mode: MapViewMode = .HalfScreenMode
    static var mapType: MKMapType = .Standard
    
    var locationAuthorizationStatus: CLAuthorizationStatus?
    
    var regionSet: Bool = false
    
    enum MapViewMode {
        case FullScreenMode
        case HalfScreenMode
    }
    
    var mapIsCentered: Bool = true {
        didSet {
            if mapIsCentered == true {
                let image = UIImage(named: "navigation")?.imageWithRenderingMode(.AlwaysTemplate)
                currentLocationButtonImageView.image = image
                currentLocationButtonImageView.tintColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            } else if mapIsCentered == false {
                let image = UIImage(named: "location")?.imageWithRenderingMode(.AlwaysTemplate)
                currentLocationButtonImageView.image = image
                if SettingsController.sharedController.theme == .darkTheme {
                    currentLocationButtonImageView.tintColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
                } else if SettingsController.sharedController.theme == .lightTheme {
                    currentLocationButtonImageView.tintColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
                }
            }
        }
    }
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpMapView()
        updateConstraintsForMode()
        
        self.view.layoutIfNeeded()
        
        buttonView.layer.cornerRadius = 8
        configureLocationManager()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadView), name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        setUpButton()
        
        if droppedPinAnnotation != nil {
            mapView.removeAnnotation(droppedPinAnnotation!)
        }
        
        tableView.reloadData()
        
        mapView.mapType = PlaceListViewController.mapType
        mapView.removeAnnotations(PlaceController.sharedController.annotations)
        mapView.addAnnotations(PlaceController.sharedController.annotations)
        
        guard let location = PlaceListViewController.locationManager.location else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        PlaceController.sharedController.region = region
        
        if SettingsController.sharedController.theme == .darkTheme {
            buttonView.backgroundColor = UIColor(red:0.40, green:0.41, blue:0.43, alpha:1.00)
            mapSizeButtonImageView.tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            currentLocationButtonImageView.tintColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
        } else if SettingsController.sharedController.theme == .lightTheme {
            buttonView.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.00)
            mapSizeButtonImageView.tintColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            currentLocationButtonImageView.tintColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        }
    }
    

    
    
    
    
    // MARK: - Reload View
    
    func reloadView() {
        self.reloadInputViews()
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    func setUpButton() {
        
        let mapImage = UIImage(named: "Map")?.imageWithRenderingMode(.AlwaysTemplate)
        mapSizeButtonImageView.image = mapImage
        mapSizeButtonImageView.tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        
        let settingsImage = UIImage(named: "Settings")?.imageWithRenderingMode(.AlwaysTemplate)
        settingsButton.frame = CGRectMake(0, 0, 23, 23)
        settingsButton.setImage(settingsImage, forState: .Normal)
        settingsButton.tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        settingsButton.addTarget(self, action: #selector(presentSettingsViewController), forControlEvents: .TouchUpInside)
        
        let settingsBarButton = UIBarButtonItem()
        settingsBarButton.customView = settingsButton
        
        self.navigationItem.leftBarButtonItem = settingsBarButton
    }
    
    func setUpMapView() {
        
        guard let location = PlaceListViewController.locationManager.location else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        let biggerSpan = MKCoordinateSpan(latitudeDelta: 15.0, longitudeDelta: 15.0)
        let biggerRegion = MKCoordinateRegion(center: location.coordinate, span: biggerSpan)
        mapView.setRegion(biggerRegion, animated: false)
        
        PlaceController.sharedController.region = region
        
        let seconds = 1.5
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per second
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            self.mapView.setRegion(region, animated: true)
        })
    }
    
    // MARK: - Map Button
    
    func updateConstraintsForMode() {
        
        if mode == .HalfScreenMode {
            constraintBetweenMapAndTableView.constant = 0
            bottomTableViewConstraint.priority = UILayoutPriorityDefaultHigh+1
            
            let mapImage = UIImage(named: "Map")?.imageWithRenderingMode(.AlwaysTemplate)
            mapSizeButtonImageView.image = mapImage
            
            mode = .FullScreenMode
        } else if mode == .FullScreenMode {
            bottomMapToViewConstraint.constant = 0
            constraintBetweenMapAndTableView.constant = 0
            bottomTableViewConstraint.priority = UILayoutPriorityDefaultHigh-1
            
            let listScreenImage = UIImage(named: "ListScreen")?.imageWithRenderingMode(.AlwaysTemplate)
            mapSizeButtonImageView.image = listScreenImage
            
            mode = .HalfScreenMode
        }
    }
    
    @IBAction func mapSizeButtonTapped(sender: AnyObject) {
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.5) {
            self.updateConstraintsForMode()
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Settings Button
    
    func presentSettingsViewController() {
        guard let settingsVC = self.storyboard?.instantiateViewControllerWithIdentifier("SettingsNavController") else { return }
        self.presentViewController(settingsVC, animated: true, completion: nil)
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if locationAuthorizationStatus == .AuthorizedWhenInUse {
            return PlaceController.sharedController.sortedPlaces.count
        } else {
            return PlaceController.sharedController.places.count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("placeListCell", forIndexPath: indexPath) as? PlaceListTableViewCell else { return UITableViewCell() }
        
        if locationAuthorizationStatus == .AuthorizedWhenInUse {
            let place = PlaceController.sharedController.sortedPlaces[indexPath.row]
            cell.updateWithPlace(place)
            return cell
        } else {
            let place = PlaceController.sharedController.places[indexPath.row]
            cell.updateWithPlace(place)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let annotations = mapView.annotations
            for annotation in annotations {
                mapView.removeAnnotation(annotation)
            }
            
            if locationAuthorizationStatus == .AuthorizedWhenInUse {
                let place = PlaceController.sharedController.sortedPlaces[indexPath.row]
                PlaceController.sharedController.deletePlace(place)
            } else {
                let place = PlaceController.sharedController.places[indexPath.row]
                PlaceController.sharedController.deletePlace(place)
            }
            
            mapView.addAnnotations(PlaceController.sharedController.annotations)
            
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let header = view as? UITableViewHeaderFooterView else { return }
        
        if SettingsController.sharedController.theme == .darkTheme {
            header.contentView.backgroundColor = UIColor(red:0.40, green:0.41, blue:0.43, alpha:1.00)
            header.textLabel?.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        } else if SettingsController.sharedController.theme == .lightTheme {
            header.contentView.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.00)
            header.textLabel?.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        }
        
        header.textLabel?.font = UIFont(name: "avenir-medium", size: 16)!
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Saved Places"
    }
    
    @IBAction func longPressGesture(sender: AnyObject) {
        
        if sender.state == .Began {
            if droppedPinAnnotation != nil {
                mapView.removeAnnotation(droppedPinAnnotation!)
            }
            
            let location = sender.locationInView(mapView)
            let coordinate = mapView.convertPoint(location, toCoordinateFromView: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "New Location"
            annotation.subtitle = "Tap to add location"
            
            self.droppedPinAnnotation = annotation
            
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    
        if let indexPath = tableView.indexPathForSelectedRow {
            
            if locationAuthorizationStatus == .AuthorizedWhenInUse {
                let place = PlaceController.sharedController.sortedPlaces[indexPath.row]
                let coordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude)
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                
                if segue.identifier == "toDetailSegue" {
                    guard let destinationVC = segue.destinationViewController as? PlaceDetailViewController else { return }
                    destinationVC.place = place
                    destinationVC.placemark = placemark
                }
            } else {
                let place = PlaceController.sharedController.places[indexPath.row]
                let coordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude)
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                
                if segue.identifier == "toDetailSegue" {
                    guard let destinationVC = segue.destinationViewController as? PlaceDetailViewController else { return }
                    destinationVC.place = place
                    destinationVC.placemark = placemark
                }
            }
        } else {
            if segue.identifier == "savePinSegue" {
                guard let destinationVC = segue.destinationViewController as? AddPlaceViewController else { return }
                destinationVC.placemark = droppedPinPlacemark
            }
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
    
    func configureLocationManager() {
        PlaceListViewController.locationManager.delegate = self
        PlaceListViewController.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        PlaceListViewController.locationManager.requestWhenInUseAuthorization()
        PlaceListViewController.locationManager.requestLocation()
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        if status == .AuthorizedWhenInUse {
            PlaceListViewController.locationManager.requestLocation()
        }
        self.locationAuthorizationStatus = status
        self.tableView.reloadData()
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
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("Error: \(error.localizedDescription)")
    }
}

extension PlaceListViewController: MKMapViewDelegate {
    
    // MARK: - Map Delegate
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        if let mapPin = annotation as? MapPin {
            if mapPin.isSaved == true {
                
                let pinView = MKPinAnnotationView(annotation: mapPin, reuseIdentifier: "pin")
                pinView.canShowCallout = true
                pinView.animatesDrop = false
                pinView.pinTintColor = .redColor()
                
                return pinView
            }
        } else {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView.canShowCallout = true
            pinView.draggable = true
            pinView.animatesDrop = true
            pinView.pinTintColor = .purpleColor()
            pinView.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
            
            return pinView
        }
        return nil
    }
    
    func mapView(mapView: MKMapView, didAddAnnotationViews views: [MKAnnotationView]) {
        
        guard let annotation = self.droppedPinAnnotation else { return }
        
        let latitude = annotation.coordinate.latitude, longitude = annotation.coordinate.longitude
        
        LocationController.sharedController.reverseGeocoding(latitude, longitude: longitude, completion: { (placemark) in
            guard let clPlacemark = placemark else { return }
            
            let pm = MKPlacemark(placemark: clPlacemark)
            
            self.droppedPinPlacemark = pm
        })
        
        let seconds = 0.5
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per second
        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        
        dispatch_after(dispatchTime, dispatch_get_main_queue(), {
            
            mapView.selectAnnotation(annotation, animated: false)
        })
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, didChangeDragState newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .Ending {
            guard let coordinate = view.annotation?.coordinate else { return }
            
            let latitude = coordinate.latitude, longitude = coordinate.longitude
            
            LocationController.sharedController.reverseGeocoding(latitude, longitude: longitude, completion: { (placemark) in
                guard let clPlacemark = placemark else { return }
                
                let pm = MKPlacemark(placemark: clPlacemark)
                
                self.droppedPinPlacemark = pm
            })
        }
    }
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapIsCentered = false
    }
    
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            
            guard let annotation = view.annotation, title = annotation.title else { print("Unable to create annotation"); return }
            
            if title == "New Location" {
                self.performSegueWithIdentifier("savePinSegue", sender: self)
            } else {
                self.performSegueWithIdentifier("toDetailSegue", sender: self)
            }
        }
    }
    
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func mapViewWillStartRenderingMap(mapView: MKMapView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}
















