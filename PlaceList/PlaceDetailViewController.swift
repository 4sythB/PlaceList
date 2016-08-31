//
//  PlaceDetailViewController.swift
//  PlaceList
//
//  Created by Brad on 8/29/16.
//  Copyright © 2016 Brad Forsyth. All rights reserved.
//

import UIKit
import MapKit

class PlaceDetailViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var placeTitleLabel: UILabel!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var cityStateZipLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var editDoneButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var place: Place?
    var placemark: MKPlacemark?
    
    var mode: ButtonMode = .ViewMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        notesTextView.delegate = self
        
        setUpView()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setUpView() {
        
        guard let placemark = placemark, place = place, notes = place.notes else { return }
        
        let title = place.title, streetAddress = place.streetAddress, city = place.city, state = place.state, zip = place.zipCode
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        
        navigationItem.title = title
        
        placeTitleLabel.text = title
        streetAddressLabel.text = streetAddress
        cityStateZipLabel.text = "\(city), \(state) \(zip)"
        notesTextView.text = notes
        
        editDoneButton.title = "Edit"
        editDoneButton.style = .Plain
    }
    
    // MARK: - View mode
    
    enum ButtonMode {
        case ViewMode
        case EditMode
    }
    
    func goToEditMode() {
        
        editDoneButton.title = "Done"
        editDoneButton.style = .Done
        mode = .EditMode
        
        notesTextView.editable = true
    }
    
    func goToViewMode() {
        
        editDoneButton.title = "Edit"
        editDoneButton.style = .Plain
        mode = .ViewMode
        
        notesTextView.editable = false
        
        guard let place = place, notes = notesTextView.text else { return }
        
        PlaceController.sharedController.updateNotesForPlace(place, notes: notes)
    }
    
    // MARK: - Action
    
    @IBAction func viewModeButtonTapped(sender: AnyObject) {
        
        switch mode {
        case .ViewMode:
            goToEditMode()
            return
            
        case .EditMode:
            goToViewMode()
            return
        }
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









