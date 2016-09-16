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
    @IBOutlet weak var notesHeadingLabel: UILabel!
    @IBOutlet weak var notesTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var mapViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var notesToAddressConstraint: NSLayoutConstraint!
    
    var place: Place?
    var placemark: MKPlacemark?
    
    var directionsButton = UIButton()
    
    let placeholderText = "Type your notes here"
    
    var mode: ButtonMode = .ViewMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        notesTextView.delegate = self
        notesTextView.editable = true
        notesTextView.layer.cornerRadius = 8.0
        
        if notesTextView.text == placeholderText {
            applyPlaceholderStyle(notesTextView, placeholderText: placeholderText)
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func setUpView() {
        setupAppearance()
        setupDirectionsButton()
        setupLabelsAndMapView()
    }
    
    func setupAppearance() {
        placeTitleLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
        notesHeadingLabel.textColor = UIColor(red:0.42, green:0.66, blue:0.76, alpha:1.00)
        
        if SettingsController.sharedController.theme == .darkTheme {
            view.backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            containerView.backgroundColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            streetAddressLabel.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            notesTextView.backgroundColor = UIColor(red:0.44, green:0.47, blue:0.51, alpha:1.00)
            notesTextView.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
            notesTextView.keyboardAppearance = .Dark
            
        } else if SettingsController.sharedController.theme == .lightTheme {
            view.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            containerView.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            streetAddressLabel.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            notesTextView.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.00)
            notesTextView.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            notesTextView.keyboardAppearance = .Default
        }
    }
    
    func setupDirectionsButton() {
        let image = UIImage(named: "Arrow")?.imageWithRenderingMode(.AlwaysTemplate)
        directionsButton.frame = CGRectMake(0, 0, 23, 23)
        directionsButton.setImage(image, forState: .Normal)
        directionsButton.tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        directionsButton.addTarget(self, action: #selector(getDirections), forControlEvents: .TouchUpInside)
        
        let directionsBarButton = UIBarButtonItem()
        directionsBarButton.customView = directionsButton
        self.navigationItem.rightBarButtonItem = directionsBarButton
    }
    
    func setupLabelsAndMapView() {
        guard let placemark = placemark, place = place, notes = place.notes else { return }
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        
        mapView.mapType = SettingsController.sharedController.mapType
        
        let title = place.title
        navigationItem.title = title
        placeTitleLabel.text = title
        notesTextView.text = notes
        
        if place.streetAddress != nil && place.city != nil && place.state != nil && place.zipCode != nil {
            guard let streetAddress = place.streetAddress, city = place.city, state = place.state, zipCode = place.zipCode else { return }
            streetAddressLabel.text = "\(streetAddress)\n\(city), \(state) \(zipCode)"
        } else if place.streetAddress == nil && place.city != nil && place.state != nil && place.zipCode != nil {
            guard let city = place.city, state = place.state, zipCode = place.zipCode else { return }
            streetAddressLabel.text = "\(city), \(state) \(zipCode)"
        } else if place.streetAddress != nil && place.city == nil && place.state != nil && place.zipCode != nil {
            guard let streetAddress = place.streetAddress, state = place.state, zipCode = place.zipCode else { return }
            streetAddressLabel.text = "\(streetAddress)\n\(state) \(zipCode)"
        } else if place.streetAddress != nil && place.city != nil && place.state == nil && place.zipCode != nil {
            guard let streetAddress = place.streetAddress, city = place.city, zipCode = place.zipCode else { return }
            streetAddressLabel.text = "\(streetAddress)\n\(city), \(zipCode)"
        } else if place.streetAddress != nil && place.city != nil && place.state != nil && place.zipCode == nil {
            guard let streetAddress = place.streetAddress, city = place.city, state = place.state else { return }
            streetAddressLabel.text = "\(streetAddress)\n\(city), \(state)"
        } else if place.streetAddress == nil && place.city == nil && place.state == nil && place.zipCode == nil {
            streetAddressLabel.hidden = true
            notesToAddressConstraint.active = false
        }
    }
    
    // MARK: - View mode
    
    enum ButtonMode {
        case ViewMode
        case EditMode
    }
    
    func goToEditMode() {
        
        directionsButton.removeFromSuperview()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: #selector(PlaceDetailViewController.goToViewMode))
        self.navigationItem.rightBarButtonItem = doneButton
        
        mode = .EditMode
        
        notesTextView.editable = true
    }
    
    func goToViewMode() {
        
        let barButton = UIBarButtonItem()
        barButton.customView = directionsButton
        self.navigationItem.rightBarButtonItem = barButton
        
        mode = .ViewMode
        
        notesTextView.resignFirstResponder()
        
        guard let place = place, notes = notesTextView.text else { return }
        
        PlaceController.sharedController.updateNotesForPlace(place, notes: notes)
    }
    
    func getDirections() {
        
        let mapItem = MKMapItem(placemark: placemark!)
        mapItem.name = place?.title
        mapItem.openInMapsWithLaunchOptions([MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    // MARK: - Action
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        goToViewMode()
    }
    
    // MARK: - Editing/saving
    
    func textViewDidBeginEditing(textView: UITextView) {
        goToEditMode()
    }
    
    override func viewWillDisappear(animated: Bool) {
        guard let place = place, notes = notesTextView.text else { return }
        
        PlaceController.sharedController.updateNotesForPlace(place, notes: notes)
    }
    
    // MARK: - TextView placeholder
    
    func applyPlaceholderStyle(textView: UITextView, placeholderText: String) {
        
        // make it look (initially) like a placeholder
        textView.textColor = UIColor.lightGrayColor()
        textView.text = placeholderText
        textView.font = UIFont(name: "avenir", size: 14)
    }
    
    func applyNonPlaceholderStyle(textView: UITextView) {
        
        // make it look like normal text instead of a placeholder
        textView.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        textView.alpha = 1.0
        textView.font = UIFont(name: "avenir", size: 14)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView == notesTextView && textView.text == placeholderText {
            // move cursor to start
            moveCursorToStart(textView)
        }
        return true
    }
    
    func moveCursorToStart(textView: UITextView) {
        dispatch_async(dispatch_get_main_queue(), {
            textView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {

        let newLength = textView.text.utf16.count + text.utf16.count - range.length
        if newLength > 0 {
            if textView == notesTextView && textView.text == placeholderText {
                if text.utf16.count == 0 {
                    return false
                }
                applyNonPlaceholderStyle(textView)
                textView.text = ""
            }
            return true
        } else {
            applyPlaceholderStyle(textView, placeholderText: placeholderText)
            moveCursorToStart(textView)
            return false
        }
    }
    
    func textViewDidChangeSelection (textView: UITextView) {
        if textView == notesTextView && textView.text == placeholderText {
            moveCursorToStart(textView)
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if notesTextView.text.characters.count == 0 {
            notesTextView.text = placeholderText
            notesTextView.textColor = .lightGrayColor()
        }
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
            
            self.view.layoutIfNeeded()
            
            UIView.animateWithDuration(0.5) {
                self.mapViewTopConstraint.constant = -keyboardSize.size.height
                self.view.layoutIfNeeded()
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        
        self.view.layoutIfNeeded()
        
        UIView.animateWithDuration(0.5) {
            self.mapViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }
    }
}

extension PlaceDetailViewController: MKMapViewDelegate {
    
    func mapViewWillStartLoadingMap(mapView: MKMapView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishLoadingMap(mapView: MKMapView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func mapViewWillStartRenderingMap(mapView: MKMapView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView, fullyRendered: Bool) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
}







