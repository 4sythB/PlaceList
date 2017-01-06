//
//  AddPlaceViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class AddPlaceViewController: UIViewController {
    
    var placemark: MKPlacemark?
    
    var detailContainerViewController: DetailContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
    }
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "embededDetailSegue" {
            
            guard let placemark = placemark else { return }
            
            detailContainerViewController = segue.destination as? DetailContainerViewController
            detailContainerViewController.placemark = placemark
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: AnyObject) {
        
        guard let placemark = placemark, let notes = detailContainerViewController.notesTextView.text else { return }
        
        PlaceController.sharedController.addPlace(placemark, notes: notes)
        
        detailContainerViewController.notesTextView.resignFirstResponder()
        self.performSegue(withIdentifier: "toPlaceListSegue", sender: self)
    }
}






