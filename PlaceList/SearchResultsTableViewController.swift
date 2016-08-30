//
//  SearchResultsTableViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class SearchResultsTableViewController: UITableViewController {
    
    static let sharedController = SearchResultsTableViewController()
    
    var resultSearchController: UISearchController? = nil
    
    var matchingItems: [MKMapItem] = []
    var mapView: MKMapView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return matchingItems.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("placeSearchCell", forIndexPath: indexPath)
        
        let item = matchingItems[indexPath.row].placemark
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = LocationController.sharedController.parseAddress(item)
        
        return cell
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

extension SearchResultsTableViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        
        guard let region = SearchTableViewController.region,
            searchBarText = searchController.searchBar.text else {
                return
        }
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        search.startWithCompletionHandler { (response, error) in
            if error != nil {
                print("Error: \(error?.localizedDescription)")
            } else {
                guard let response = response else { return }
                self.matchingItems = response.mapItems
                self.tableView.reloadData()
            }
        }
    }
}














