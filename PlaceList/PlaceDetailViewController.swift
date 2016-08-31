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
    
    func adjustInsetForKeyboardShow(show: Bool, notification: NSNotification) {
        guard let value = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue else { return }
        let keyboardFrame = value.CGRectValue()
        let adjustmentHeight = (CGRectGetHeight(keyboardFrame) + 20) * (show ? 1 : -1)
        scrollView.contentInset.bottom += adjustmentHeight
        scrollView.scrollIndicatorInsets.bottom += adjustmentHeight
    }
    
    func keyboardWillShow(notification: NSNotification) {
        adjustInsetForKeyboardShow(true, notification: notification)
    }
    
    func keyboardWillHide(notification: NSNotification) {
        adjustInsetForKeyboardShow(false, notification: notification)
    }
    
//    func keyboardWillShow(notification: NSNotification) {
//        
//        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue() {
//            animateViewMoving(true, moveValue: keyboardSize.height)
//        }
//    }

//    func textViewDidBeginEditing(textView: UITextView) {
//        animateViewMoving(true, moveValue: 150)
//    }
//    
//    func textViewDidEndEditing(textView: UITextView) {
//        animateViewMoving(false, moveValue: 150)
//    }
//    
//    func animateViewMoving (up:Bool, moveValue :CGFloat){
//        let movementDuration:NSTimeInterval = 0.3
//        let movement:CGFloat = ( up ? -moveValue : moveValue)
//        
//        UIView.beginAnimations("animateView", context: nil)
//        UIView.setAnimationBeginsFromCurrentState(true)
//        UIView.setAnimationDuration(movementDuration)
//        
//        self.view.frame = CGRectOffset(self.view.frame, 0, movement)
//        UIView.commitAnimations()
//    }
    

}









