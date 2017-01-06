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
    
    var locationAuthorizationStatus: CLAuthorizationStatus?
    
    var regionSet: Bool = false
    
    let settingsButton = UIButton()
    
    var droppedPinAnnotation: MKAnnotation?
    var droppedPinPlacemark: MKPlacemark?
    
    var mode: MapViewMode = .halfScreenMode
    
    enum MapViewMode {
        case fullScreenMode
        case halfScreenMode
    }
    
    var mapIsCentered: Bool = true {
        didSet {
            if mapIsCentered == true {
                let image = UIImage(named: "navigation")?.withRenderingMode(.alwaysTemplate)
                currentLocationButtonImageView.image = image
                currentLocationButtonImageView.tintColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
            } else if mapIsCentered == false {
                let image = UIImage(named: "location")?.withRenderingMode(.alwaysTemplate)
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
        setUpButtons()
        updateConstraintsForMode()
        configureLocationManager()
        
        self.view.layoutIfNeeded()
        
        buttonView.layer.cornerRadius = 8
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        configureButtonViews()
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadView), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        if droppedPinAnnotation != nil {
            mapView.removeAnnotation(droppedPinAnnotation!)
        }
        
        tableView.reloadData()
        
        mapView.mapType = SettingsController.sharedController.mapType
        mapView.removeAnnotations(PlaceController.sharedController.annotations)
        mapView.addAnnotations(PlaceController.sharedController.annotations)
        
        guard let location = PlaceListViewController.locationManager.location else { return }
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: location.coordinate, span: span)
        PlaceController.sharedController.region = region
    }

    // MARK: - Reload View
    
    func reloadView() {
        self.reloadInputViews()
        tableView.reloadData()
    }
    
    // MARK: - Setup
    
    func configureButtonViews() {
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
    
    func setUpButtons() {
        
        let mapImage = UIImage(named: "Map")?.withRenderingMode(.alwaysTemplate)
        mapSizeButtonImageView.image = mapImage
        mapSizeButtonImageView.tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        
        let settingsImage = UIImage(named: "Settings")?.withRenderingMode(.alwaysTemplate)
        settingsButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        settingsButton.setImage(settingsImage, for: UIControlState())
        settingsButton.tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        settingsButton.addTarget(self, action: #selector(presentSettingsViewController), for: .touchUpInside)
        
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
        let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            self.mapView.setRegion(region, animated: true)
        })
    }
    
    // MARK: - Map Button
    
    @IBAction func mapSizeButtonTapped(_ sender: AnyObject) {
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.updateConstraintsForMode()
            self.view.layoutIfNeeded()
        }) 
    }
    
    func updateConstraintsForMode() {
        
        if mode == .halfScreenMode {
            constraintBetweenMapAndTableView.constant = 0
            bottomTableViewConstraint.priority = UILayoutPriorityDefaultHigh+1
            
            let mapImage = UIImage(named: "Map")?.withRenderingMode(.alwaysTemplate)
            mapSizeButtonImageView.image = mapImage
            
            mode = .fullScreenMode
        } else if mode == .fullScreenMode {
            bottomMapToViewConstraint.constant = 0
            constraintBetweenMapAndTableView.constant = 0
            bottomTableViewConstraint.priority = UILayoutPriorityDefaultHigh-1
            
            let listScreenImage = UIImage(named: "ListScreen")?.withRenderingMode(.alwaysTemplate)
            mapSizeButtonImageView.image = listScreenImage
            
            mode = .halfScreenMode
        }
    }
    
    // MARK: - Settings Button
    
    func presentSettingsViewController() {
        guard let settingsVC = self.storyboard?.instantiateViewController(withIdentifier: "SettingsNavController") else { return }
        self.present(settingsVC, animated: true, completion: nil)
    }
    
    // MARK: - Long press gesture
    
    @IBAction func longPressGesture(_ sender: AnyObject) {
        
        if sender.state == .began {
            if droppedPinAnnotation != nil {
                mapView.removeAnnotation(droppedPinAnnotation!)
            }
            
            let location = sender.location(in: mapView)
            let coordinate = mapView.convert(location, toCoordinateFrom: mapView)
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "New Location"
            annotation.subtitle = "Tap to add location"
            
            self.droppedPinAnnotation = annotation
            
            mapView.addAnnotation(annotation)
        }
    }
    
    // MARK: - Current location button action
    
    @IBAction func currentLocationButtonTapped(_ sender: AnyObject) {
        
        if let location = PlaceListViewController.locationManager.location {
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: true)
            PlaceController.sharedController.region = region
        }
        mapIsCentered = true
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if locationAuthorizationStatus == .authorizedWhenInUse {
            return PlaceController.sharedController.sortedPlaces.count
        } else {
            return PlaceController.sharedController.places.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "placeListCell", for: indexPath) as? PlaceListTableViewCell else { return UITableViewCell() }
        
        if locationAuthorizationStatus == .authorizedWhenInUse {
            let place = PlaceController.sharedController.sortedPlaces[indexPath.row]
            cell.updateWithPlace(place)
            return cell
        } else {
            let place = PlaceController.sharedController.places[indexPath.row]
            cell.updateWithPlace(place)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let annotations = mapView.annotations
            for annotation in annotations {
                mapView.removeAnnotation(annotation)
            }
            
            if locationAuthorizationStatus == .authorizedWhenInUse {
                let place = PlaceController.sharedController.sortedPlaces[indexPath.row]
                PlaceController.sharedController.deletePlace(place)
            } else {
                let place = PlaceController.sharedController.places[indexPath.row]
                PlaceController.sharedController.deletePlace(place)
            }
            
            mapView.addAnnotations(PlaceController.sharedController.annotations)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
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
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "My Saved Places"
    }
    
    // MARK: - Navigation
    
    @IBAction func prepareForUnwind(_ segue: UIStoryboardSegue) {
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let indexPath = tableView.indexPathForSelectedRow {
            
            guard let destinationVC = segue.destination as? PlaceDetailViewController else { return }
            
            if locationAuthorizationStatus == .authorizedWhenInUse {
                let place = PlaceController.sharedController.sortedPlaces[indexPath.row]
                let coordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude)
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                
                if segue.identifier == "toDetailSegue" {
                    destinationVC.place = place
                    destinationVC.placemark = placemark
                }
            } else {
                let place = PlaceController.sharedController.places[indexPath.row]
                let coordinates = CLLocationCoordinate2DMake(place.latitude, place.longitude)
                let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
                
                if segue.identifier == "toDetailSegue" {
                    destinationVC.place = place
                    destinationVC.placemark = placemark
                }
            }
        } else {
            if segue.identifier == "savePinSegue" {
                guard let destinationVC = segue.destination as? AddPlaceViewController else { return }
                destinationVC.placemark = droppedPinPlacemark
            }
        }
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
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status == .authorizedWhenInUse {
            PlaceListViewController.locationManager.requestLocation()
        }
        self.locationAuthorizationStatus = status
        self.tableView.reloadData()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if regionSet == false {
            guard let location = locations.first else { return }
            let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            let region = MKCoordinateRegion(center: location.coordinate, span: span)
            mapView.setRegion(region, animated: false)
            PlaceController.sharedController.region = region
            regionSet = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

// MARK: - Map Delegate

extension PlaceListViewController: MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        if let mapPin = annotation as? MapPin {
            if mapPin.isSaved == true {
                
                let pinView = MKPinAnnotationView(annotation: mapPin, reuseIdentifier: "pin")
                pinView.canShowCallout = true
                pinView.animatesDrop = false
                pinView.pinTintColor = .red
                
                return pinView
            }
        } else {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
            pinView.canShowCallout = true
            pinView.isDraggable = true
            pinView.animatesDrop = true
            pinView.pinTintColor = .purple
            pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            
            return pinView
        }
        return nil
    }
    
    func mapView(_ mapView: MKMapView, didAdd views: [MKAnnotationView]) {
        
        guard let annotation = self.droppedPinAnnotation else { return }
        
        let latitude = annotation.coordinate.latitude, longitude = annotation.coordinate.longitude
        
        LocationController.sharedController.reverseGeocoding(latitude, longitude: longitude, completion: { (placemark) in
            guard let clPlacemark = placemark else { return }
            
            let pm = MKPlacemark(placemark: clPlacemark)
            self.droppedPinPlacemark = pm
        })
        
        let seconds = 0.5
        let delay = seconds * Double(NSEC_PER_SEC)  // nanoseconds per second
        let dispatchTime = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
            
            mapView.selectAnnotation(annotation, animated: false)
        })
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, didChange newState: MKAnnotationViewDragState, fromOldState oldState: MKAnnotationViewDragState) {
        if newState == .ending {
            guard let coordinate = view.annotation?.coordinate else { return }
            let latitude = coordinate.latitude, longitude = coordinate.longitude
            
            LocationController.sharedController.reverseGeocoding(latitude, longitude: longitude, completion: { (placemark) in
                guard let clPlacemark = placemark else { return }
                
                let pm = MKPlacemark(placemark: clPlacemark)
                self.droppedPinPlacemark = pm
            })
        }
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        mapIsCentered = false
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == view.rightCalloutAccessoryView {
            guard let annotation = view.annotation, let title = annotation.title else { print("Unable to create annotation"); return }
            
            if title == "New Location" {
                self.performSegue(withIdentifier: "savePinSegue", sender: self)
            } else {
                self.performSegue(withIdentifier: "toDetailSegue", sender: self)
            }
        }
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}
















