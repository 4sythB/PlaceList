//
//  PlaceDetailViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class PlaceDetailViewController: UIViewController {
    
    var place: Place?
    var placemark: MKPlacemark?
    
    var detailContainerViewController: DetailContainerViewController!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "enbededContainerSegue" {
            detailContainerViewController = segue.destinationViewController as? DetailContainerViewController
            detailContainerViewController.placemark = placemark
        }
    }
}
