//
//  SearchTableViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class SearchTableViewController: UITableViewController {
    
    var resultsSearchController: CustomSearchController? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .None
        
        configureResultsSearchController()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.resultsSearchController?.active = true
            self.resultsSearchController?.searchBar.becomeFirstResponder()
        }
    }
    
    func configureResultsSearchController() {
        let locationSearchTable = storyboard?.instantiateViewControllerWithIdentifier("SearchResultsTableViewController") as? SearchResultsTableViewController
        
        resultsSearchController = CustomSearchController(searchViewController: locationSearchTable)
        resultsSearchController?.delegate = self
        
        guard let resultsSearchController = resultsSearchController else { return }
        resultsSearchController.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultsSearchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.searchBarStyle = .Default
        
        if SettingsController.sharedController.theme == .darkTheme {
            searchBar.keyboardAppearance = .Dark
        } else if SettingsController.sharedController.theme == .lightTheme {
            searchBar.keyboardAppearance = .Default
        }
        
        navigationItem.titleView = resultsSearchController.searchBar
        
        resultsSearchController.hidesNavigationBarDuringPresentation = false
        resultsSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    // MARK: - Action
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        resultsSearchController?.searchBar.resignFirstResponder()
        self.performSegueWithIdentifier("toListSegue", sender: self)
    }
    
    // MARK: - Table view data source
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toAddPlaceSegue" {
            guard let destinationVC = segue.destinationViewController as? AddPlaceViewController, resultsController = resultsSearchController?.searchResultsController as? SearchResultsTableViewController, tableView = resultsController.tableView, indexPath = tableView.indexPathForSelectedRow else { return }
            
            let placemark = resultsController.matchingItems[indexPath.row].placemark
            
            destinationVC.placemark = placemark
        }
    }
}

extension SearchTableViewController: UISearchControllerDelegate {
    
    func didPresentSearchController(searchController: UISearchController) {
        
        dispatch_async(dispatch_get_main_queue()) {
            self.resultsSearchController?.active = true
            self.resultsSearchController?.searchBar.becomeFirstResponder()
        }
    }
}






