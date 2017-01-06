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
        
        tableView.separatorStyle = .none
        
        configureResultsSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        DispatchQueue.main.async {
            self.resultsSearchController?.isActive = true
            self.resultsSearchController?.searchBar.becomeFirstResponder()
        }
    }
    
    func configureResultsSearchController() {
        let locationSearchTable = storyboard?.instantiateViewController(withIdentifier: "SearchResultsTableViewController") as? SearchResultsTableViewController
        
        resultsSearchController = CustomSearchController(searchViewController: locationSearchTable)
        resultsSearchController?.delegate = self
        
        guard let resultsSearchController = resultsSearchController else { return }
        resultsSearchController.searchResultsUpdater = locationSearchTable
        
        let searchBar = resultsSearchController.searchBar
        searchBar.sizeToFit()
        searchBar.placeholder = "Search for places"
        searchBar.searchBarStyle = .default
        
        if SettingsController.sharedController.theme == .darkTheme {
            searchBar.keyboardAppearance = .dark
        } else if SettingsController.sharedController.theme == .lightTheme {
            searchBar.keyboardAppearance = .default
        }
        
        navigationItem.titleView = resultsSearchController.searchBar
        
        resultsSearchController.hidesNavigationBarDuringPresentation = false
        resultsSearchController.dimsBackgroundDuringPresentation = true
        definesPresentationContext = true
    }
    
    // MARK: - Action
    
    @IBAction func cancelButtonTapped(_ sender: AnyObject) {
        resultsSearchController?.searchBar.resignFirstResponder()
        self.performSegue(withIdentifier: "toListSegue", sender: self)
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toAddPlaceSegue" {
            guard let destinationVC = segue.destination as? AddPlaceViewController, let resultsController = resultsSearchController?.searchResultsController as? SearchResultsTableViewController, let tableView = resultsController.tableView, let indexPath = tableView.indexPathForSelectedRow else { return }
            
            let placemark = resultsController.matchingItems[indexPath.row].placemark
            
            destinationVC.placemark = placemark
        }
    }
}

extension SearchTableViewController: UISearchControllerDelegate {
    
    func didPresentSearchController(_ searchController: UISearchController) {
        
        DispatchQueue.main.async {
            self.resultsSearchController?.isActive = true
            self.resultsSearchController?.searchBar.becomeFirstResponder()
        }
    }
}






