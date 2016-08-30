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

//    @IBOutlet weak var detailContainerView: UIView!
    
    var place: MKPlacemark? = nil
    
    var detailContainerViewController: DetailContainerViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "embededDetailSegue" {
            
            guard let place = place else { return }
            
            detailContainerViewController = segue.destinationViewController as? DetailContainerViewController
            detailContainerViewController.place = place
        }
    }
}
