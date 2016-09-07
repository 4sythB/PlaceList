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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let mapRegion = region {
            mapView.setRegion(mapRegion, animated: true)
        }

        let locationSearchTable = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsTableViewController") as? SearchResultsTableViewController
        
        resultsSearchController = UISearchController(searchResultsController: locationSearchTable)
        
        resultsSearchController?.delegate = self
        
        guard let resultsSearchController = resultsSearchController else { return }
        
        resultsSearchController.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultsSearchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.searchBarStyle = .Minimal
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

extension MapViewController: UISearchControllerDelegate {
    
    func didPresentSearchController(searchController: UISearchController) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.resultsSearchController?.active = true
            self.resultsSearchController?.searchBar.becomeFirstResponder()
        }
    }
}








