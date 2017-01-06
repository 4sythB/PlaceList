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
    
    var mode: ButtonMode = .viewMode
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpView()
        
        notesTextView.delegate = self
        notesTextView.isEditable = true
        notesTextView.layer.cornerRadius = 8.0
        
        if notesTextView.text == placeholderText {
            applyPlaceholderStyle(notesTextView, placeholderText: placeholderText)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
            notesTextView.keyboardAppearance = .dark
            
        } else if SettingsController.sharedController.theme == .lightTheme {
            view.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            containerView.backgroundColor = UIColor(red:0.93, green:0.94, blue:0.95, alpha:1.00)
            streetAddressLabel.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            notesTextView.backgroundColor = UIColor(red:0.75, green:0.75, blue:0.75, alpha:1.00)
            notesTextView.textColor = UIColor(red:0.19, green:0.20, blue:0.23, alpha:1.00)
            notesTextView.keyboardAppearance = .default
        }
    }
    
    func setupDirectionsButton() {
        let image = UIImage(named: "Arrow")?.withRenderingMode(.alwaysTemplate)
        directionsButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        directionsButton.setImage(image, for: UIControlState())
        directionsButton.tintColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        directionsButton.addTarget(self, action: #selector(getDirections), for: .touchUpInside)
        
        let directionsBarButton = UIBarButtonItem()
        directionsBarButton.customView = directionsButton
        self.navigationItem.rightBarButtonItem = directionsBarButton
    }
    
    func setupLabelsAndMapView() {
        guard let placemark = placemark, let place = place, let notes = place.notes else { return }
        
        LocationController.sharedController.dropPinZoomIn(placemark, mapView: mapView)
        
        mapView.mapType = SettingsController.sharedController.mapType
        
        let title = place.title
        navigationItem.title = title
        placeTitleLabel.text = title
        notesTextView.text = notes
        
        if place.streetAddress != nil && place.city != nil && place.state != nil && place.zipCode != nil {
            guard let streetAddress = place.streetAddress, let city = place.city, let state = place.state, let zipCode = place.zipCode else { return }
            streetAddressLabel.text = "\(streetAddress)\n\(city), \(state) \(zipCode)"
        } else if place.streetAddress == nil && place.city != nil && place.state != nil && place.zipCode != nil {
            guard let city = place.city, let state = place.state, let zipCode = place.zipCode else { return }
            streetAddressLabel.text = "\(city), \(state) \(zipCode)"
        } else if place.streetAddress != nil && place.city == nil && place.state != nil && place.zipCode != nil {
            guard let streetAddress = place.streetAddress, let state = place.state, let zipCode = place.zipCode else { return }
            streetAddressLabel.text = "\(streetAddress)\n\(state) \(zipCode)"
        } else if place.streetAddress != nil && place.city != nil && place.state == nil && place.zipCode != nil {
            guard let streetAddress = place.streetAddress, let city = place.city, let zipCode = place.zipCode else { return }
            streetAddressLabel.text = "\(streetAddress)\n\(city), \(zipCode)"
        } else if place.streetAddress != nil && place.city != nil && place.state != nil && place.zipCode == nil {
            guard let streetAddress = place.streetAddress, let city = place.city, let state = place.state else { return }
            streetAddressLabel.text = "\(streetAddress)\n\(city), \(state)"
        } else if place.streetAddress == nil && place.city == nil && place.state == nil && place.zipCode == nil {
            streetAddressLabel.isHidden = true
            notesToAddressConstraint.isActive = false
        }
    }
    
    // MARK: - View mode
    
    enum ButtonMode {
        case viewMode
        case editMode
    }
    
    func goToEditMode() {
        
        directionsButton.removeFromSuperview()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(PlaceDetailViewController.goToViewMode))
        self.navigationItem.rightBarButtonItem = doneButton
        
        mode = .editMode
        
        notesTextView.isEditable = true
    }
    
    func goToViewMode() {
        
        let barButton = UIBarButtonItem()
        barButton.customView = directionsButton
        self.navigationItem.rightBarButtonItem = barButton
        
        mode = .viewMode
        
        notesTextView.resignFirstResponder()
        
        guard let place = place, let notes = notesTextView.text else { return }
        
        PlaceController.sharedController.updateNotesForPlace(place, notes: notes)
    }
    
    func getDirections() {
        
        let mapItem = MKMapItem(placemark: placemark!)
        mapItem.name = place?.title
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving])
    }
    
    // MARK: - Action
    
    @IBAction func doneButtonTapped(_ sender: AnyObject) {
        goToViewMode()
    }
    
    // MARK: - Editing/saving
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        goToEditMode()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        guard let place = place, let notes = notesTextView.text else { return }
        
        PlaceController.sharedController.updateNotesForPlace(place, notes: notes)
    }
    
    // MARK: - TextView placeholder
    
    func applyPlaceholderStyle(_ textView: UITextView, placeholderText: String) {
        
        // make it look (initially) like a placeholder
        textView.textColor = UIColor.lightGray
        textView.text = placeholderText
        textView.font = UIFont(name: "avenir", size: 14)
    }
    
    func applyNonPlaceholderStyle(_ textView: UITextView) {
        
        // make it look like normal text instead of a placeholder
        textView.textColor = UIColor(red: 236/255, green: 240/255, blue: 241/255, alpha: 1.0)
        textView.alpha = 1.0
        textView.font = UIFont(name: "avenir", size: 14)
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView == notesTextView && textView.text == placeholderText {
            // move cursor to start
            moveCursorToStart(textView)
        }
        return true
    }
    
    func moveCursorToStart(_ textView: UITextView) {
        DispatchQueue.main.async(execute: {
            textView.selectedRange = NSMakeRange(0, 0);
        })
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

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
    
    func textViewDidChangeSelection (_ textView: UITextView) {
        if textView == notesTextView && textView.text == placeholderText {
            moveCursorToStart(textView)
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if notesTextView.text.characters.count == 0 {
            notesTextView.text = placeholderText
            notesTextView.textColor = .lightGray
        }
    }
    
    // MARK: - Keyboard
    
    func keyboardWillShow(_ notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            self.view.layoutIfNeeded()
            
            UIView.animate(withDuration: 0.5, animations: {
                self.mapViewTopConstraint.constant = -keyboardSize.size.height
                self.view.layoutIfNeeded()
            }) 
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        self.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            self.mapViewTopConstraint.constant = 0
            self.view.layoutIfNeeded()
        }) 
    }
}

extension PlaceDetailViewController: MKMapViewDelegate {
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
}







