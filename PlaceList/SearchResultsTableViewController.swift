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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return matchingItems.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "placeSearchCell", for: indexPath)
        
        let item = matchingItems[indexPath.row].placemark
        
        if SettingsController.sharedController.theme == .darkTheme {
            cell.textLabel?.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            cell.detailTextLabel?.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        } else if SettingsController.sharedController.theme == .lightTheme {
            cell.textLabel?.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            cell.detailTextLabel?.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
        }
        
        cell.textLabel?.text = item.name
        cell.detailTextLabel?.text = LocationController.sharedController.parseAddress(item)
        
        return cell
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let indexPath = tableView.indexPathForSelectedRow else { return }
        let placemark = matchingItems[indexPath.row].placemark
        
        if segue.identifier == "toAddPlaceSegue" {
            guard let destinationVC = segue.destination as? AddPlaceViewController else { return }
            destinationVC.placemark = placemark
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let presentingVC = self.presentingViewController as? SearchTableViewController, let cell = tableView.cellForRow(at: indexPath) else { return }
        
        presentingVC.performSegue(withIdentifier: "toAddPlaceSegue", sender: cell)
    }
}

extension SearchResultsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        
        guard let region = PlaceController.sharedController.region,
            let searchBarText = searchController.searchBar.text else { return }
        
        let request = MKLocalSearchRequest()
        request.naturalLanguageQuery = searchBarText
        request.region = region
        
        let search = MKLocalSearch(request: request)
        
        if searchBarText.characters.count > 0 {
            search.start { (response, error) in
                if error != nil {
                    print("Error: \(error?.localizedDescription)")
                } else {
                    guard let response = response else { return }
                    self.matchingItems = response.mapItems
                    self.tableView.reloadData()
                }
            }
        } else if searchBarText.characters.count == 0 {
            search.cancel()
        }
    }
}














