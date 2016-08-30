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
    
    var placemark: MKPlacemark? = nil
    
    var detailContainerViewController: DetailContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    // MARK: - Actions
    
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        
        guard let placemark = placemark else { return }
        
        PlaceController.sharedController.addPlace(placemark, notes: nil)
        
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}






