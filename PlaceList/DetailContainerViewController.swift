//
//  DetailContainerViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class DetailContainerViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var cityStateZipLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var placemark: MKPlacemark? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notesTextView.delegate = self
        
        setUpContainerView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setUpContainerView() {
        
        guard let placemark = placemark, title = placemark.name, subThoroughfare = placemark.subThoroughfare, thoroughfare = placemark.thoroughfare, city = placemark.locality, state = placemark.administrativeArea, zip = placemark.postalCode else { return }
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        
        let streetAddress = "\(subThoroughfare) \(thoroughfare)"
        
        placeTitleLabel.text = title
        streetAddressLabel.text = streetAddress
        cityStateZipLabel.text = "\(city), \(state) \(zip)"
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            let contentInset = UIEdgeInsetsMake(0, 0, keyboardSize.size.height, 0)
            scrollView.contentInset = contentInset
            scrollView.scrollIndicatorInsets = contentInset
            
            scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height)
            
            scrollView.scrollRectToVisible((notesTextView.superview?.frame)!, animated: true)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        let contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        scrollView.contentInset = contentInset
        scrollView.scrollIndicatorInsets = contentInset
        
        scrollView.contentSize = CGSizeMake(scrollView.contentSize.width, scrollView.contentSize.height)
    }
}






