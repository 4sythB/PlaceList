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
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "embededDetailSegue" {
            
            guard let placemark = placemark else { return }
            
            detailContainerViewController = segue.destinationViewController as? DetailContainerViewController
            detailContainerViewController.placemark = placemark
        }
    }

    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        guard let placemark = placemark, notes = detailContainerViewController.notesTextView.text else { return }
        
        PlaceController.sharedController.addPlace(placemark, notes: notes)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}






